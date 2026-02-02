from __future__ import annotations

import base64
import re
import quopri
from pathlib import Path


def extract_email_content(emlx_path: Path) -> dict[str, str | dict[str, str]]:
    raw = emlx_path.read_bytes()
    first_nl = raw.find(b"\n")
    if first_nl == -1:
        text = raw.decode("utf-8", errors="ignore")
        return {"headers": {}, "body": text}

    try:
        byte_count = int(raw[:first_nl].strip())
    except ValueError:
        byte_count = len(raw) - first_nl - 1

    email_bytes = raw[first_nl + 1 : first_nl + 1 + byte_count]
    email_text = email_bytes.decode("utf-8", errors="ignore")

    header_end = email_text.find("\n\n")
    if header_end < 0:
        header_end = email_text.find("\r\n\r\n")

    if header_end > 0:
        headers_raw = email_text[:header_end]
        body_raw = email_text[header_end:]
    else:
        headers_raw = ""
        body_raw = email_text

    headers: dict[str, str] = {}
    for hdr in ["From", "To", "Subject", "Date", "Content-Type", "Content-Transfer-Encoding"]:
        match = re.search(
            rf"^{hdr}:\s*(.+?)(?=\n[^\s]|\n\n|\Z)",
            headers_raw,
            re.MULTILINE | re.DOTALL,
        )
        if match:
            val = match.group(1).strip()
            val = re.sub(r"\r?\n\s+", " ", val)
            headers[hdr] = val

    cte = headers.get("Content-Transfer-Encoding", "").lower()
    if "quoted-printable" in cte:
        try:
            body = quopri.decodestring(body_raw.encode()).decode("utf-8", errors="ignore")
        except Exception:
            body = body_raw
    elif "base64" in cte:
        try:
            body = base64.b64decode(body_raw.encode()).decode("utf-8", errors="ignore")
        except Exception:
            body = body_raw
    else:
        body = body_raw

    return {"headers": headers, "body": body}
