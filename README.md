# Apple Mail Exporter

Search and export emails from Apple Mail's local database by keyword.

## Install

```bash
brew install aayush9029/tap/apple-mail-exporter
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

Searches are **case-insensitive** and multiple keywords are OR'd.

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `-o, --output <dir>` | Output directory | `output` |
| `-l, --limit <n>` | Max emails to export (0 = all) | `0` |
| `--list-only` | List matches without exporting | |
| `-i, --interactive` | Interactive mode | |
| `--mail-dir <dir>` | Override Mail V* directory | |
| `--mail-base <dir>` | Override Mail base directory | |

> Requires Full Disk Access for your terminal (System Settings > Privacy & Security > Full Disk Access).
