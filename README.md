# Apple Mail Exporter

Search and export emails from Apple Mail's local database by keyword.

## Install

```bash
brew install aayush9029/tap/apple-mail-exporter
```

## Usage

```bash
apple-mail-exporter                                    # interactive mode
apple-mail-exporter airbnb --output receipts           # search + export
apple-mail-exporter receipt invoice payment --list-only # list matches only
apple-mail-exporter airbnb --limit 10                  # limit results
apple-mail-exporter -o ~/exports -l 50 "newsletter"    # custom output dir
```

> Requires Full Disk Access for your terminal (System Settings > Privacy & Security > Full Disk Access).

---

*More CLI tools: [`brew tap aayush9029/tap`](https://github.com/Aayush9029/homebrew-tap)*
