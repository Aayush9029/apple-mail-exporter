from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from .config import resolve_mail_config
from .db import search_emails
from .emlx import extract_email_content
from .mailbox import find_emlx, mailbox_url_to_path
from .models import EmailRecord
from .utils import normalize_timestamp, sanitize_filename


@dataclass(frozen=True)
class ExportOptions:
    output_dir: Path
    limit: int = 0
    list_only: bool = False


def _resolve_output_dir(output: str | Path) -> Path:
    path = Path(output).expanduser()
    if not path.is_absolute():
        path = Path.cwd() / path
    path.mkdir(parents=True, exist_ok=True)
    return path


def export_email(msg: EmailRecord, output_dir: Path, index: int, mail_dir: Path) -> Path | None:
    mailbox_path = mailbox_url_to_path(msg.mailbox_url, mail_dir)
    emlx_path = find_emlx(msg.msg_id, mailbox_path) if mailbox_path else None

    date_str = normalize_timestamp(msg.date_sent_raw)[:10]
    subject = msg.subject or "no-subject"
    sender = msg.sender_name or msg.sender_address or "unknown"

    if emlx_path:
        content = extract_email_content(emlx_path)
        headers = content["headers"]
        body = content["body"]
    else:
        headers = {}
        body = "(Email body not available locally — only metadata from index)"

    safe_subject = sanitize_filename(subject)
    filename = f"{index:03d}_{date_str}_{safe_subject}.md"
    out_path = output_dir / filename

    with out_path.open("w", encoding="utf-8") as handle:
        handle.write(f"# {subject}\n\n")
        handle.write("| Field | Value |\n|---|---|\n")
        handle.write(f"| **From** | {sender} <{msg.sender_address or ''}> |\n")
        handle.write(f"| **Date** | {date_str} |\n")
        handle.write(f"| **Subject** | {subject} |\n")
        handle.write(f"| **Message ID** | {msg.msg_id} |\n")
        handle.write(f"| **Mailbox** | {msg.mailbox_url or ''} |\n")
        if emlx_path:
            handle.write(f"| **Source** | `{emlx_path.name}` |\n")
        handle.write("\n---\n\n")

        if headers:
            handle.write("## Headers\n\n```\n")
            for key, value in headers.items():
                handle.write(f"{key}: {value}\n")
            handle.write("```\n\n")

        handle.write("## Body\n\n")
        if "<html" in str(body).lower() or "<!doctype" in str(body).lower():
            handle.write("```html\n")
            handle.write(str(body))
            handle.write("\n```\n")
        else:
            handle.write(str(body))
            handle.write("\n")

    return out_path


def run_export(
    keywords: Iterable[str],
    output: str | Path = "output",
    limit: int = 0,
    list_only: bool = False,
    mail_dir: Path | None = None,
    mail_base: Path | None = None,
) -> list[Path]:
    config = resolve_mail_config(mail_dir=mail_dir, mail_base=mail_base)
    output_dir = _resolve_output_dir(output)

    results = search_emails(config.envelope_db, keywords, limit=limit)

    if not results:
        return []

    if list_only:
        return []

    exported_paths: list[Path] = []
    for i, msg in enumerate(results, 1):
        path = export_email(msg, output_dir, i, config.mail_dir)
        if path:
            exported_paths.append(path)

    return exported_paths


def list_matches(
    keywords: Iterable[str],
    limit: int = 0,
    mail_dir: Path | None = None,
    mail_base: Path | None = None,
) -> list[EmailRecord]:
    config = resolve_mail_config(mail_dir=mail_dir, mail_base=mail_base)
    return search_emails(config.envelope_db, keywords, limit=limit)
