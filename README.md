# Apple Mail Exporter

![CI](https://github.com/Aayush9029/apple-mail-exporter/actions/workflows/ci.yml/badge.svg?branch=main)

Search and export emails from Apple Mail's local database by keyword.

## Install

### Homebrew (recommended)

```bash
brew tap Aayush9029/tap
brew install apple-mail-exporter
```

Zero dependencies — downloads a prebuilt universal binary (arm64 + x86_64).

### From source

```bash
git clone https://github.com/Aayush9029/apple-mail-exporter.git
cd apple-mail-exporter
swift build -c release
cp .build/release/apple-mail-exporter /usr/local/bin/
```

## Usage

```bash
# Interactive mode
apple-mail-exporter

# Search with keywords (case-insensitive)
apple-mail-exporter airbnb --output receipts

# Multiple keywords (matches any)
apple-mail-exporter receipt invoice payment --list-only

# Limit results
apple-mail-exporter airbnb --limit 10
```

Searches are **case-insensitive** — `airbnb`, `Airbnb`, and `AIRBNB` all match the same emails. Multiple keywords are OR'd: any match counts.

## How it works

Queries Apple Mail's Envelope Index SQLite database
(`~/Library/Mail/V*/MailData/Envelope Index`) to search subjects and sender info,
then reads `.emlx` files to extract full email content. Exports each match as a
Markdown file.

## Configuration

Override Mail locations if needed:

- `APPLE_MAIL_DIR` — point at a specific `V*` directory
- `APPLE_MAIL_BASE` — point at the Mail base directory

CLI flags:

- `--mail-dir /path/to/V*`
- `--mail-base /path/to/Mail`

## Requirements

- macOS 13+ (Ventura or later)
- Full Disk Access granted to your terminal (System Settings > Privacy & Security > Full Disk Access)

## Development

```bash
swift build
swift test
```

## License

MIT
