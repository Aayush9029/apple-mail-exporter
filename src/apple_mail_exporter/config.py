from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import os
import re


@dataclass(frozen=True)
class MailConfig:
    mail_base: Path
    mail_dir: Path
    envelope_db: Path


def _env_path(name: str) -> Path | None:
    value = os.environ.get(name)
    if not value:
        return None
    return Path(value).expanduser()


def find_mail_version_dir(base: Path) -> Path:
    if not base.exists():
        raise FileNotFoundError(f"Apple Mail directory not found: {base}")

    candidates = sorted(
        [d for d in base.iterdir() if d.is_dir() and re.match(r"^V\d+$", d.name)],
        key=lambda d: int(d.name[1:]),
        reverse=True,
    )
    if not candidates:
        raise FileNotFoundError(f"No Mail version directory (V*) found in {base}")
    return candidates[0]


def resolve_mail_config(mail_dir: Path | None = None, mail_base: Path | None = None) -> MailConfig:
    env_dir = _env_path("APPLE_MAIL_DIR")
    env_base = _env_path("APPLE_MAIL_BASE")

    resolved_base = mail_base or env_base or (Path.home() / "Library" / "Mail")
    resolved_dir = mail_dir or env_dir or find_mail_version_dir(resolved_base)
    envelope_db = resolved_dir / "MailData" / "Envelope Index"

    return MailConfig(mail_base=resolved_base, mail_dir=resolved_dir, envelope_db=envelope_db)


def mac_epoch_offset_seconds() -> int:
    unix_epoch = datetime(1970, 1, 1, tzinfo=timezone.utc)
    mac_epoch = datetime(2001, 1, 1, tzinfo=timezone.utc)
    return int((mac_epoch - unix_epoch).total_seconds())
