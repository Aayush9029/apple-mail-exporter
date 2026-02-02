from pathlib import Path

from apple_mail_exporter.emlx import extract_email_content


def test_extract_email_content(tmp_path: Path):
    email_bytes = (
        b"From: Example <a@b.com>\n"
        b"Subject: Hi\n"
        b"Content-Transfer-Encoding: quoted-printable\n"
        b"\n"
        b"Hello=0AWorld"
    )
    payload = str(len(email_bytes)).encode() + b"\n" + email_bytes + b"\n"
    emlx = tmp_path / "1.emlx"
    emlx.write_bytes(payload)

    content = extract_email_content(emlx)
    headers = content["headers"]
    body = content["body"]

    assert headers["Subject"] == "Hi"
    assert "Hello" in body
    assert "World" in body
