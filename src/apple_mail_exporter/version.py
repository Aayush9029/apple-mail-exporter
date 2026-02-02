"""Version helpers."""

from importlib.metadata import version as _version


def get_version() -> str:
    return _version("apple-mail-exporter")


__all__ = ["get_version"]
