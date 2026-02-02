# Apple Mail Exporter
![CI](https://github.com/Aayush9029/apple-mail-exporter/actions/workflows/ci.yml/badge.svg?branch=main)

Search and export emails from Apple Mail's local database by keyword.

## Install

### Homebrew (recommended)

```bash
brew tap Aayush9029/tap
brew install apple-mail-exporter
```

### pip

```bash
pip install apple-mail-exporter
```

### From source (dev)

```bash
uv venv
uv pip install -e ".[dev]"
```

## Usage

```bash
# Interactive mode
apple-mail-exporter

# CLI mode
apple-mail-exporter "Air Canada" "aircanada" --output receipts
apple-mail-exporter "receipt" "invoice" --list-only
apple-mail-exporter "Airbnb" --limit 10

# Run as a module
python -m apple_mail_exporter "Airbnb" --limit 10
```

## How it works

Queries Apple Mail's Envelope Index SQLite database
(`~/Library/Mail/V*/MailData/Envelope Index`) to search subjects and sender info,
then reads `.emlx` files to extract full email content. Exports each match as a
Markdown file.

## Configuration

You can override Mail locations if needed:

- `APPLE_MAIL_DIR` to point at a specific `V*` directory
- `APPLE_MAIL_BASE` to point at the Mail base directory

CLI flags:

- `--mail-dir /path/to/V*`
- `--mail-base /path/to/Mail`

## Requirements

- macOS with Apple Mail
- Python 3.10+
- Full Disk Access granted to your terminal (for reading Mail data)

## Development

```bash
uv pip install -e ".[dev]"
pytest
```

## Build

```bash
uv build
```

## Version

```bash
apple-mail-exporter --version
```
