from copy import deepcopy
from uuid import uuid4

import pytest
from pymongo.errors import DuplicateKeyError


class FakeInsertResult:
    def __init__(self, inserted_id):
        self.inserted_id = inserted_id


class FakeUpdateResult:
    def __init__(self, matched_count=0, modified_count=0):
        self.matched_count = matched_count
        self.modified_count = modified_count


class FakeDeleteResult:
    def __init__(self, deleted_count=0):
        self.deleted_count = deleted_count


class FakeCursor:
    def __init__(self, documents):
        self.documents = documents

    def sort(self, *args, **kwargs):
        return self

    def skip(self, count):
        self.documents = self.documents[count:]
        return self

    def limit(self, count):
        self.documents = self.documents[:count]
        return self

    def __iter__(self):
        return iter(deepcopy(self.documents))


class FakeCollection:
    def __init__(self):
        self.documents = []
        self.unique_fields = set()

    def create_index(self, keys, **kwargs):
        if kwargs.get("unique"):
            for field, _ in keys:
                self.unique_fields.add(field)
        return kwargs.get("name", "test_index")

    def _matches(self, document, query):
        if not query:
            return True

        for key, value in query.items():
            if key == "$or":
                if not any(self._matches(document, item) for item in value):
                    return False
            elif isinstance(value, dict):
                if "$type" in value:
                    actual = document.get(key)
                    if value["$type"] == "string" and not isinstance(actual, str):
                        return False
                elif "$in" in value:
                    if document.get(key) not in value["$in"]:
                        return False
                elif "$ne" in value:
                    if document.get(key) == value["$ne"]:
                        return False
                else:
                    if document.get(key) != value:
                        return False
            elif document.get(key) != value:
                return False

        return True

    def _project(self, document, projection):
        if not projection:
            return deepcopy(document)

        if any(value == 1 for value in projection.values()):
            result = {
                key: deepcopy(document[key])
                for key, value in projection.items()
                if value == 1 and key in document
            }
            if projection.get("_id", 1) and "_id" in document:
                result["_id"] = deepcopy(document["_id"])
            return result

        result = deepcopy(document)
        for key, value in projection.items():
            if value == 0:
                result.pop(key, None)
        return result

    def find_one(self, query=None, projection=None, **kwargs):
        for document in self.documents:
            if self._matches(document, query or {}):
                return self._project(document, projection)
        return None

    def find(self, query=None, projection=None, **kwargs):
        results = [
            self._project(document, projection)
            for document in self.documents
            if self._matches(document, query or {})
        ]
        return FakeCursor(results)

    def count_documents(self, query=None):
        return sum(
            1 for document in self.documents if self._matches(document, query or {})
        )

    def insert_one(self, document, **kwargs):
        stored = deepcopy(document)
        stored.setdefault("_id", str(uuid4()))

        for field in self.unique_fields:
            value = stored.get(field)
            if value is not None and any(
                item.get(field) == value for item in self.documents
            ):
                raise DuplicateKeyError(f"Duplicate value for unique field: {field}")

        self.documents.append(stored)
        return FakeInsertResult(stored["_id"])

    def update_one(self, query, update, **kwargs):
        for document in self.documents:
            if self._matches(document, query):
                if "$set" in update:
                    document.update(deepcopy(update["$set"]))
                return FakeUpdateResult(1, 1)
        return FakeUpdateResult()

    def update_many(self, query, update, **kwargs):
        matched = 0
        for document in self.documents:
            if self._matches(document, query):
                matched += 1
                if "$set" in update:
                    document.update(deepcopy(update["$set"]))
        return FakeUpdateResult(matched, matched)

    def delete_one(self, query, **kwargs):
        for index, document in enumerate(self.documents):
            if self._matches(document, query):
                del self.documents[index]
                return FakeDeleteResult(1)
        return FakeDeleteResult()


class FakeDatabase:
    def __init__(self):
        self.collections = {}

    def __getitem__(self, collection_name):
        if collection_name not in self.collections:
            self.collections[collection_name] = FakeCollection()
        return self.collections[collection_name]

    def get_collection(self, collection_name):
        return self[collection_name]


class FakeAdmin:
    def command(self, command_name):
        return {"ok": 1}


class FakeMongoClient:
    def __init__(self):
        self.admin = FakeAdmin()
        self.databases = {}

    def __getitem__(self, database_name):
        if database_name not in self.databases:
            self.databases[database_name] = FakeDatabase()
        return self.databases[database_name]

    def close(self):
        pass


@pytest.fixture
def fake_mongo(monkeypatch):
    from app.db import mongo

    fake_client = FakeMongoClient()

    monkeypatch.setattr(
        mongo,
        "get_mongodb_client",
        lambda: fake_client,
    )

    monkeypatch.setattr(
        mongo,
        "check_mongodb",
        lambda: True,
    )

    return fake_client


@pytest.fixture(autouse=True)
def mock_mongodb(fake_mongo):
    return fake_mongo
