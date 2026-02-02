from __future__ import annotations

from datetime import datetime, timezone
import re

from .config import mac_epoch_offset_seconds


def sanitize_filename(value: str, max_len: int = 80) -> str:
    safe = re.sub(r"[<>:\"/\\|?*\x00-\x1f]", "_", value)
    safe = re.sub(r"\s+", "_", safe)
    safe = re.sub(r"_+", "_", safe).strip("_ ")
    return safe[:max_len] if safe else "untitled"


def normalize_timestamp(raw: int | float | None) -> str:
    if not raw:
        return "unknown"

    ts = float(raw)
    if ts > 1_000_000_000_000:
        ts /= 1000.0

    if ts < 1_000_000_000:
        ts += mac_epoch_offset_seconds()

    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
