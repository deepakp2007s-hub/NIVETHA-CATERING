import logging
import os
from pathlib import Path
from threading import Lock
from typing import Iterable, Optional

import firebase_admin
from firebase_admin import credentials, messaging


logger = logging.getLogger("nivetha_catering.fcm")
_INITIALIZATION_LOCK = Lock()
DEFAULT_CREDENTIALS_FILENAME = (
    "nivetha-catering-firebase-adminsdk-fbsvc-14ada43752.json"
)


def _resolve_credentials_path() -> Optional[str]:
    """Find the Firebase service-account file without depending on cwd."""
    backend_root = Path(__file__).resolve().parents[2]
    search_roots = list(dict.fromkeys([Path.cwd(), backend_root]))

    configured_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
    if configured_path:
        configured = Path(configured_path).expanduser()
        candidates = (
            [configured]
            if configured.is_absolute()
            else [root / configured for root in search_roots]
        )
        for candidate in candidates:
            if candidate.is_file():
                return str(candidate.resolve())

    for root in search_roots:
        exact_candidate = root / DEFAULT_CREDENTIALS_FILENAME
        if exact_candidate.is_file():
            return str(exact_candidate.resolve())

    for root in search_roots:
        for match in sorted(root.glob("*firebase-adminsdk*.json")):
            if match.is_file():
                return str(match.resolve())

    return None


def _init_firebase() -> bool:
    """Initialize the default Firebase app once per Python process."""
    if firebase_admin._apps:
        return True

    with _INITIALIZATION_LOCK:
        if firebase_admin._apps:
            return True

        credential_path = _resolve_credentials_path()
        if not credential_path:
            logger.warning(
                "Firebase Admin credentials were not found; push notifications are disabled."
            )
            return False

        try:
            firebase_admin.initialize_app(
                credentials.Certificate(credential_path)
            )
            logger.info("Firebase Admin initialized using %s", credential_path)
            return True
        except Exception:
            logger.exception("Firebase Admin initialization failed.")
            return False


def send_fcm_notification(
    token: Optional[str],
    title: str,
    body: str,
    data: Optional[dict[str, str]] = None,
) -> Optional[str]:
    """Send one Firebase Cloud Messaging notification.

    Returns the Firebase message ID on success, or None when no token,
    credentials, initialized app, or successful delivery is available.
    """
    if not isinstance(token, str) or not token.strip():
        return None

    try:
        if not _init_firebase():
            return None

        string_data = {
            str(key): str(value)
            for key, value in (data or {}).items()
            if value is not None
        }

        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=string_data,
            token=token.strip(),
        )
        message_id = messaging.send(message, app=firebase_admin.get_app())
        logger.info("FCM notification sent successfully.")
        return message_id

    except Exception:
        logger.exception("Failed to send FCM push notification.")
        return None


def send_fcm_to_tokens(
    tokens: Iterable[Optional[str]],
    title: str,
    body: str,
    data: Optional[dict[str, str]] = None,
) -> int:
    """Send a push notification to unique non-empty tokens and return sent count."""
    sent_count = 0
    seen_tokens: set[str] = set()

    for raw_token in tokens:
        if not isinstance(raw_token, str):
            continue
        token = raw_token.strip()
        if not token or token in seen_tokens:
            continue
        seen_tokens.add(token)

        if send_fcm_notification(token=token, title=title, body=body, data=data):
            sent_count += 1

    return sent_count