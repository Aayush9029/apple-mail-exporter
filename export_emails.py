#!/usr/bin/env python3
"""Backward-compatible entry point.

Use `apple-mail-exporter` or `python -m apple_mail_exporter` instead.
"""

from apple_mail_exporter.cli import main

if __name__ == "__main__":
    main()
