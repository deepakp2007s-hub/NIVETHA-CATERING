import time
from collections import defaultdict, deque

from fastapi import HTTPException, Request, status

from app.core.config import settings


class SimpleRateLimiter:
    def __init__(self, max_requests: int = 10, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._hits: dict[str, deque[float]] = defaultdict(deque)

    def _get_client_ip(self, request: Request) -> str:
        forwarded_for = request.headers.get("x-forwarded-for")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()

        if request.client and request.client.host:
            return request.client.host

        return "unknown"

    async def __call__(self, request: Request) -> None:
        if settings.APP_ENV == "testing":
            return

        client_ip = self._get_client_ip(request)
        key = f"{client_ip}:{request.url.path}"
        now = time.monotonic()
        cutoff = now - self.window_seconds

        timestamps = self._hits[key]
        while timestamps and timestamps[0] < cutoff:
            timestamps.popleft()

        if len(timestamps) >= self.max_requests:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many attempts. Please wait a minute and try again.",
            )

        timestamps.append(now)


auth_rate_limiter = SimpleRateLimiter(max_requests=10, window_seconds=60)