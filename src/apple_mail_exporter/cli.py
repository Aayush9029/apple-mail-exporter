from __future__ import annotations

import argparse
from pathlib import Path

from .exporter import list_matches, run_export
from .utils import normalize_timestamp, sanitize_filename


def _print_preview(results, limit: int = 10) -> None:
    preview_count = min(limit, len(results))
    for i, msg in enumerate(results[:preview_count], 1):
        date = normalize_timestamp(msg.date_sent_raw)[:10]
        sender = msg.sender_name or msg.sender_address or "?"
        subject = (msg.subject or "?")[:65]
        print(f"  {i:3d}. [{date}] {sender}: {subject}")
    if len(results) > preview_count:
        print(f"  ... and {len(results) - preview_count} more")


def interactive(mail_dir: Path | None = None, mail_base: Path | None = None) -> None:
    print("=" * 50)
    print("  Apple Mail Email Exporter (interactive)")
    print("=" * 50)
    print()
    print("  Type comma-separated keywords to search.")
    print("  Commands:  q/quit  = exit")
    print("             help    = show usage")
    print()

    while True:
        try:
            raw = input("keywords> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nBye!")
            break

        if not raw:
            continue
        if raw.lower() in ("q", "quit", "exit"):
            print("Bye!")
            break
        if raw.lower() == "help":
            print()
            print("  Enter comma-separated keywords to search subject/sender.")
            print("  Examples:")
            print("    Air Canada, aircanada")
            print("    Airbnb")
            print("    receipt, invoice, payment")
            print()
            print("  After search you'll be asked:")
            print("    - Output folder name")
            print("    - Max results (0 = all)")
            print("    - Preview only or full export")
            print()
            continue

        keywords = [k.strip() for k in raw.split(",") if k.strip()]
        if not keywords:
            print("  No keywords entered.\n")
            continue

        results = list_matches(keywords, mail_dir=mail_dir, mail_base=mail_base)
        print(f"\n  Found {len(results)} emails.\n")
        if not results:
            continue

        _print_preview(results)
        print()

        try:
            action = input("  [e]xport / [l]ist all / [s]kip? (e/l/s) ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print("\nBye!")
            break

        if action in ("s", "skip", ""):
            print()
            continue

        if action in ("l", "list"):
            for i, msg in enumerate(results, 1):
                date = normalize_timestamp(msg.date_sent_raw)[:10]
                sender = msg.sender_name or msg.sender_address or "?"
                subject = msg.subject or "?"
                print(f"  {i:3d}. [{date}] {sender}: {subject}")
            print()
            continue

        if action in ("e", "export"):
            default_folder = "output/" + sanitize_filename(keywords[0].lower())
            try:
                folder = input(f"  Output folder [{default_folder}]: ").strip()
            except (EOFError, KeyboardInterrupt):
                print("\nBye!")
                break
            if not folder:
                folder = default_folder

            try:
                limit_str = input("  Max emails (0 = all) [0]: ").strip()
            except (EOFError, KeyboardInterrupt):
                print("\nBye!")
                break
            limit = int(limit_str) if limit_str.isdigit() else 0

            exported = run_export(
                keywords,
                output=folder,
                limit=limit,
                mail_dir=mail_dir,
                mail_base=mail_base,
            )
            print(f"\nExported {len(exported)} emails to {folder}/\n")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Export emails from Apple Mail by keyword search.",
        epilog="Run with no arguments for interactive mode.",
    )
    parser.add_argument(
        "keywords",
        nargs="*",
        help="Keywords to search (subject, sender address, sender name). Any match counts.",
    )
    parser.add_argument(
        "--output",
        "-o",
        default="output",
        help="Output directory (default: output)",
    )
    parser.add_argument(
        "--limit",
        "-l",
        type=int,
        default=0,
        help="Max number of emails to export (0 = all)",
    )
    parser.add_argument(
        "--list-only",
        action="store_true",
        help="Just list matching emails without exporting",
    )
    parser.add_argument(
        "--interactive",
        "-i",
        action="store_true",
        help="Run in interactive mode",
    )
    parser.add_argument(
        "--version",
        action="store_true",
        help="Print version and exit",
    )
    parser.add_argument(
        "--mail-dir",
        type=Path,
        default=None,
        help="Override the Mail V* directory (or set APPLE_MAIL_DIR)",
    )
    parser.add_argument(
        "--mail-base",
        type=Path,
        default=None,
        help="Override the Mail base directory (or set APPLE_MAIL_BASE)",
    )
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.version:
        from .version import get_version

        print(get_version())
        return

    if args.interactive or not args.keywords:
        interactive(mail_dir=args.mail_dir, mail_base=args.mail_base)
        return

    results = list_matches(
        args.keywords,
        limit=args.limit,
        mail_dir=args.mail_dir,
        mail_base=args.mail_base,
    )
    print(f"\nSearching for: {', '.join(args.keywords)}")
    print(f"Found {len(results)} matching emails.\n")

    if not results:
        return

    if args.list_only:
        for i, msg in enumerate(results, 1):
            date = normalize_timestamp(msg.date_sent_raw)[:10]
            sender = msg.sender_name or msg.sender_address or "?"
            subject = msg.subject or "?"
            print(f"  {i:3d}. [{date}] {sender}: {subject}")
        return

    exported = run_export(
        args.keywords,
        output=args.output,
        limit=args.limit,
        mail_dir=args.mail_dir,
        mail_base=args.mail_base,
    )

    for path in exported:
        print(f"  [{path.name.split('_')[1]}] {path.name}")

    print(f"\nExported {len(exported)} emails to {Path(args.output).expanduser()}\n")


if __name__ == "__main__":
    main()
