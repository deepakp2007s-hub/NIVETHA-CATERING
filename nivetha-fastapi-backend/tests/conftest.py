
import re
import sys
from copy import deepcopy

import pytest
from bson import ObjectId
from fastapi.testclient import TestClient
from pymongo import ReturnDocument


class FakeResult:
    def __init__(
        self,
        inserted_id=None,
        inserted_ids=None,
        matched_count=0,
        modified_count=0,
        deleted_count=0,
        upserted_id=None,
    ):
        self.inserted_id = inserted_id
        self.inserted_ids = inserted_ids or []
        self.matched_count = matched_count
        self.modified_count = modified_count
        self.deleted_count = deleted_count
        self.upserted_id = upserted_id


class FakeCursor:
    def __init__(self, documents):
        self.documents = deepcopy(documents)

    def sort(self, key, direction=1):
        reverse = direction == -1
        self.documents.sort(
            key=lambda item: item.get(key),
            reverse=reverse,
        )
        return self

    def skip(self, count):
        self.documents = self.documents[count:]
        return self

    def limit(self, count):
        if count >= 0:
            self.documents = self.documents[:count]
        return self

    def __iter__(self):
        return iter(deepcopy(self.documents))

    def __len__(self):
        return len(self.documents)


class FakeCollection:
    def __init__(self):
        self.documents = []

    @staticmethod
    def _get_value(document, key):
        value = document

        for part in key.split("."):
            if not isinstance(value, dict):
                return None
            value = value.get(part)

        return value

    @classmethod
    def _matches_condition(cls, value, condition):
        if not isinstance(condition, dict):
            return value == condition

        for operator, expected in condition.items():
            if operator == "$eq":
                if value != expected:
                    return False

            elif operator == "$ne":
                if value == expected:
                    return False

            elif operator == "$exists":
                exists = value is not None
                if exists != bool(expected):
                    return False

            elif operator == "$in":
                if value not in expected:
                    return False

            elif operator == "$nin":
                if value in expected:
                    return False

            elif operator == "$gt":
                if value is None or value <= expected:
                    return False

            elif operator == "$gte":
                if value is None or value < expected:
                    return False

            elif operator == "$lt":
                if value is None or value >= expected:
                    return False

            elif operator == "$lte":
                if value is None or value > expected:
                    return False

            elif operator == "$regex":
                if value is None or re.search(expected, str(value)) is None:
                    return False

            elif operator == "$options":
                continue

            else:
                return False

        return True

    @classmethod
    def _matches(cls, document, query):
        if not query:
            return True

        for key, expected in query.items():
            if key == "$and":
                if not all(cls._matches(document, item) for item in expected):
                    return False

            elif key == "$or":
                if not any(cls._matches(document, item) for item in expected):
                    return False

            elif key == "$nor":
                if any(cls._matches(document, item) for item in expected):
                    return False

            else:
                value = cls._get_value(document, key)

                if not cls._matches_condition(value, expected):
                    return False

        return True

    @staticmethod
    def _apply_projection(document, projection):
        if not projection:
            return deepcopy(document)

        included = [
            key for key, value in projection.items()
            if value == 1
        ]

        if included:
            result = {
                key: deepcopy(document[key])
                for key in included
                if key in document
            }

            if projection.get("_id", 1) != 0 and "_id" in document:
                result["_id"] = deepcopy(document["_id"])

            return result

        result = deepcopy(document)

        for key, value in projection.items():
            if value == 0:
                result.pop(key, None)

        return result

    def insert_one(self, document):
        stored = deepcopy(document)
        stored.setdefault("_id", ObjectId())

        if any(
            item.get("_id") == stored["_id"]
            for item in self.documents
        ):
            raise ValueError("Duplicate _id in fake collection.")

        self.documents.append(stored)
        return FakeResult(inserted_id=stored["_id"])

    def insert_many(self, documents):
        inserted_ids = []

        for document in documents:
            result = self.insert_one(document)
            inserted_ids.append(result.inserted_id)

        return FakeResult(inserted_ids=inserted_ids)

    def find_one(self, query=None, projection=None, **kwargs):
        for document in self.documents:
            if self._matches(document, query or {}):
                return self._apply_projection(document, projection)

        return None

    def find(self, query=None, projection=None, **kwargs):
        matched = [
            self._apply_projection(document, projection)
            for document in self.documents
            if self._matches(document, query or {})
        ]

        return FakeCursor(matched)

    def count_documents(self, query=None):
        return sum(
            1
            for document in self.documents
            if self._matches(document, query or {})
        )

    @staticmethod
    def _apply_update(document, update, inserting=False):
        modified = False

        if not any(key.startswith("$") for key in update):
            old_id = document.get("_id")
            document.clear()
            document.update(deepcopy(update))
            document.setdefault("_id", old_id)
            return True

        for operator, values in update.items():
            if operator == "$set":
                for key, value in values.items():
                    if document.get(key) != value:
                        document[key] = deepcopy(value)
                        modified = True

            elif operator == "$setOnInsert" and inserting:
                for key, value in values.items():
                    if key not in document:
                        document[key] = deepcopy(value)
                        modified = True

            elif operator == "$unset":
                for key in values:
                    if key in document:
                        document.pop(key)
                        modified = True

            elif operator == "$inc":
                for key, value in values.items():
                    document[key] = document.get(key, 0) + value
                    modified = True

            elif operator == "$push":
                for key, value in values.items():
                    document.setdefault(key, []).append(deepcopy(value))
                    modified = True

            elif operator == "$addToSet":
                for key, value in values.items():
                    current = document.setdefault(key, [])
                    if value not in current:
                        current.append(deepcopy(value))
                        modified = True

            elif operator == "$pull":
                for key, value in values.items():
                    current = document.get(key, [])
                    updated = [
                        item for item in current if item != value
                    ]
                    if updated != current:
                        document[key] = updated
                        modified = True

        return modified

    @staticmethod
    def _build_upsert_document(query):
        document = {}

        for key, value in query.items():
            if key.startswith("$"):
                continue

            if isinstance(value, dict):
                continue

            document[key] = deepcopy(value)

        return document

    def update_one(self, query, update, upsert=False):
        for document in self.documents:
            if self._matches(document, query):
                modified = self._apply_update(document, update)

                return FakeResult(
                    matched_count=1,
                    modified_count=int(modified),
                )

        if upsert:
            new_document = self._build_upsert_document(query)
            self._apply_update(new_document, update, inserting=True)
            new_document.setdefault("_id", ObjectId())
            self.documents.append(new_document)

            return FakeResult(upserted_id=new_document["_id"])

        return FakeResult()

    def update_many(self, query, update):
        matched = 0
        modified = 0

        for document in self.documents:
            if self._matches(document, query):
                matched += 1
                if self._apply_update(document, update):
                    modified += 1

        return FakeResult(
            matched_count=matched,
            modified_count=modified,
        )

    def find_one_and_update(
        self,
        query,
        update,
        projection=None,
        return_document=ReturnDocument.BEFORE,
        upsert=False,
        **kwargs,
    ):
        for document in self.documents:
            if self._matches(document, query):
                before = deepcopy(document)
                self._apply_update(document, update)

                result = (
                    document
                    if return_document == ReturnDocument.AFTER
                    else before
                )

                return self._apply_projection(result, projection)

        if not upsert:
            return None

        new_document = self._build_upsert_document(query)
        self._apply_update(new_document, update, inserting=True)
        new_document.setdefault("_id", ObjectId())
        self.documents.append(new_document)

        result = (
            new_document
            if return_document == ReturnDocument.AFTER
            else None
        )

        if result is None:
            return None

        return self._apply_projection(result, projection)

    def delete_one(self, query):
        for index, document in enumerate(self.documents):
            if self._matches(document, query):
                self.documents.pop(index)
                return FakeResult(deleted_count=1)

        return FakeResult()

    def delete_many(self, query):
        original_count = len(self.documents)

        self.documents = [
            document
            for document in self.documents
            if not self._matches(document, query)
        ]

        return FakeResult(
            deleted_count=original_count - len(self.documents)
        )

    def drop(self):
        self.documents.clear()

    def create_index(self, *args, **kwargs):
        return "fake_index"

    def create_indexes(self, *args, **kwargs):
        return []

    def distinct(self, key, filter=None):
        values = []

        for document in self.documents:
            if self._matches(document, filter or {}):
                value = self._get_value(document, key)
                if value not in values:
                    values.append(value)

        return values


class FakeDatabase:
    def __init__(self):
        self.collections = {}

    def __getitem__(self, name):
        if name not in self.collections:
            self.collections[name] = FakeCollection()

        return self.collections[name]

    def get_collection(self, name):
        return self[name]

    def list_collection_names(self):
        return list(self.collections)


@pytest.fixture
def fake_database():
    return FakeDatabase()


@pytest.fixture(autouse=True)
def isolate_mongodb(monkeypatch, fake_database):
    import app.api.auth as auth
    import app.api.bookings as bookings
    import app.api.customers as customers
    import app.api.foods as foods
    import app.api.notifications as notifications
    import app.api.profiles as profiles
    import app.api.reports as reports
    import app.api.reviews as reviews
    import app.db.mongo as mongo

    monkeypatch.setattr(mongo, "customer_db", fake_database)
    monkeypatch.setattr(mongo, "owner_db", fake_database)

    collection_mappings = {
        auth: {
            "customers": "customers",
            "login_rate_limits": "login_rate_limits",
        },
        bookings: {
            "bookings": "bookings",
            "customers": "customers",
            "notifications": "notifications",
        },
        customers: {
            "customers_collection": "customers",
        },
        foods: {
            "foods_collection": "foods",
        },
        notifications: {
            "notifications_collection": "notifications",
        },
        profiles: {
            "customers_collection": "customers",
        },
        reports: {
            "bookings_collection": "bookings",
        },
        reviews: {
            "reviews_collection": "reviews",
            "customers_collection": "customers",
        },
    }

    for module, mappings in collection_mappings.items():
        for variable_name, collection_name in mappings.items():
            monkeypatch.setattr(
                module,
                variable_name,
                fake_database[collection_name],
            )

    # Patch aliases imported directly inside test modules.
    for module_name in ("tests.test_bookings", "test_bookings"):
        test_module = sys.modules.get(module_name)

        if test_module is not None and hasattr(
            test_module,
            "customers_collection",
        ):
            monkeypatch.setattr(
                test_module,
                "customers_collection",
                fake_database["customers"],
            )


@pytest.fixture
def client():
    from app.main import app

    with TestClient(app) as test_client:
        yield test_client
