from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Iterable

from .models import EmailRecord


def get_db_connection(envelope_db: Path) -> sqlite3.Connection:
    if not envelope_db.exists():
        raise FileNotFoundError(f"Mail database not found: {envelope_db}")
    return sqlite3.connect(str(envelope_db))


def search_emails(envelope_db: Path, keywords: Iterable[str], limit: int = 0) -> list[EmailRecord]:
    kw_list = [kw for kw in keywords if kw]
    if not kw_list:
        return []

    conn = get_db_connection(envelope_db)
    conn.row_factory = sqlite3.Row

    where_clauses = []
    params: list[str] = []
    for kw in kw_list:
        pattern = f"%{kw}%"
        where_clauses.append("(s.subject LIKE ? OR a.address LIKE ? OR a.comment LIKE ?)")
        params.extend([pattern, pattern, pattern])

    where_sql = " OR ".join(where_clauses)
    limit_sql = f"LIMIT {limit}" if limit > 0 else ""

    query = f"""
        SELECT
            m.ROWID as msg_id,
            s.subject,
            a.address as sender_address,
            a.comment as sender_name,
            m.date_sent as date_sent_raw,
            mb.url as mailbox_url
        FROM messages m
        JOIN subjects s ON m.subject = s.ROWID
        LEFT JOIN addresses a ON m.sender = a.ROWID
        LEFT JOIN mailboxes mb ON m.mailbox = mb.ROWID
        WHERE {where_sql}
        ORDER BY m.date_sent DESC
        {limit_sql}
    """

    rows = conn.execute(query, params).fetchall()
    conn.close()

    return [EmailRecord.from_row(r) for r in rows]
