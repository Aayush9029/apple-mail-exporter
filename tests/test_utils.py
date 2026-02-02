from apple_mail_exporter.utils import normalize_timestamp, sanitize_filename
from apple_mail_exporter.config import mac_epoch_offset_seconds


def test_sanitize_filename():
    assert sanitize_filename("Hello: World?") == "Hello_World"
    assert sanitize_filename("   ") == "untitled"


def test_normalize_timestamp_unix():
    ts = 1_700_000_000
    result = normalize_timestamp(ts)
    assert result.startswith("2023") or result.startswith("2024")


def test_normalize_timestamp_mac_epoch():
    mac_ts = 100_000_000
    result = normalize_timestamp(mac_ts)
    offset = mac_epoch_offset_seconds()
    assert result.startswith("200")
    assert offset > 900_000_000
