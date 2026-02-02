from __future__ import annotations

from pathlib import Path
import os
import re
from urllib.parse import unquote


def mailbox_url_to_path(url: str | None, mail_dir: Path) -> Path | None:
    if not url:
        return None

    match = re.match(r"(?:imap|local)://([^/]+)/(.+)", url)
    if not match:
        return None

    account_uuid = match.group(1)
    path_part = unquote(match.group(2))

    segments = path_part.split("/")
    mbox_path = mail_dir / account_uuid
    for seg in segments:
        mbox_path = mbox_path / f"{seg}.mbox"

    return mbox_path


def find_emlx(msg_id: int, mailbox_path: Path) -> Path | None:
    if not mailbox_path or not mailbox_path.exists():
        return None

    fname = f"{msg_id}.emlx"
    partial_fname = f"{msg_id}.partial.emlx"

    for root, _dirs, files in os.walk(mailbox_path):
        if fname in files:
            return Path(root) / fname
        if partial_fname in files:
            return Path(root) / partial_fname
    return None
