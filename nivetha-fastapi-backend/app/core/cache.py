import time
from typing import Any, Optional

_CACHE: dict[str, tuple[float, Any]] = {}


def get_cache(key: str) -> Optional[Any]:
    entry = _CACHE.get(key)
    if not entry:
        return None
    expires_at, value = entry
    if time.monotonic() > expires_at:
        _CACHE.pop(key, None)
        return None
    return value


def set_cache(key: str, value: Any, ttl_seconds: int = 120) -> None:
    _CACHE[key] = (time.monotonic() + ttl_seconds, value)


def clear_cache(prefix: Optional[str] = None) -> None:
    if prefix is None:
        _CACHE.clear()
        return
    for key in [k for k in _CACHE if k.startswith(prefix)]:
        _CACHE.pop(key, None)