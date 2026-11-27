import glob
import logging
import os
from typing import Optional

import firebase_admin
from firebase_admin import credentials, messaging

logger = logging.getLogger("nivetha_catering.fcm")


def _resolve_credentials_path() -> Optional[str]:
    env_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
    if env_path:
        resolved = env_path if os.path.isabs(env_path) else os.path.join(os.getcwd(), env_path)
        if os.path.exists(resolved):
            return resolved

    exact_default = os.path.join(os.getcwd(), "nivetha-catering-firebase-adminsdk-fbsvc-14ada43752.json")
    if os.path.exists(exact_default):
        return exact_default

    matched = glob.glob(os.path.join(os.getcwd(), "*firebase-adminsdk*.json"))
    return matched[0] if matched else None


def _init_firebase() -> None:
    if firebase_admin._apps:
        return

    cred_path = _resolve_credentials_path()
    if cred_path:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin initialized using %s", cred_path)
    else:
        logger.warning("Firebase service account JSON not found in backend directory")


def send_fcm_notification(
    token: Optional[str],
    title: str,
    body: str,
    data: Optional[dict[str, str]] = None,
) -> Optional[str]:
    if not token:
        return None

    _init_firebase()
    if not firebase_admin._apps:
        return None

    string_data = {str(k): str(v) for k, v in (data or {}).items() if v is not None}

    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=string_data,
            token=token,
        )
        message_id = messaging.send(message)
        logger.info("FCM push sent: %s", message_id)
        return message_id
    except Exception:
        logger.exception("Failed to send FCM push notification")
        return None