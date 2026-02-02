from pathlib import Path

from apple_mail_exporter.mailbox import mailbox_url_to_path


def test_mailbox_url_to_path_imap():
    mail_dir = Path("/Mail")
    url = "imap://UUID/INBOX"
    assert mailbox_url_to_path(url, mail_dir) == Path("/Mail/UUID/INBOX.mbox")


def test_mailbox_url_to_path_nested():
    mail_dir = Path("/Mail")
    url = "imap://UUID/[Gmail]/All%20Mail"
    assert mailbox_url_to_path(url, mail_dir) == Path("/Mail/UUID/[Gmail].mbox/All Mail.mbox")
