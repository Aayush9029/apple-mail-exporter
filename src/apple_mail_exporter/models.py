from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class EmailRecord:
    msg_id: int
    subject: str | None
    sender_address: str | None
    sender_name: str | None
    date_sent_raw: int | float | None
    mailbox_url: str | None

    @classmethod
    def from_row(cls, row: Any) -> "EmailRecord":
        return cls(
            msg_id=row["msg_id"],
            subject=row["subject"],
            sender_address=row["sender_address"],
            sender_name=row["sender_name"],
            date_sent_raw=row["date_sent_raw"],
            mailbox_url=row["mailbox_url"],
        )
