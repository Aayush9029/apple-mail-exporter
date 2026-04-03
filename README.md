<p align="center">
  <img src="assets/icon.png" width="128" alt="apple-mail-exporter">
  <h1 align="center">apple-mail-exporter</h1>
  <p align="center">Search and export emails from Apple Mail's local database</p>
</p>

<p align="center">
  <a href="https://github.com/Aayush9029/apple-mail-exporter/releases/latest"><img src="https://img.shields.io/github/v/release/Aayush9029/apple-mail-exporter" alt="Release"></a>
  <a href="https://github.com/Aayush9029/apple-mail-exporter/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Aayush9029/apple-mail-exporter" alt="License"></a>
</p>

## Install

```bash
brew install aayush9029/tap/apple-mail-exporter
```

Or tap first:

```bash
brew tap aayush9029/tap
brew install apple-mail-exporter
```

Requires Full Disk Access (System Settings > Privacy & Security > Full Disk Access).

## Usage

```bash
apple-mail-exporter                                    # interactive mode
apple-mail-exporter airbnb --output receipts           # search + export
apple-mail-exporter receipt invoice payment --list-only # list matches only
apple-mail-exporter airbnb --limit 10                  # limit results
apple-mail-exporter -o ~/exports -l 50 "newsletter"    # custom output dir
```

## License

MIT
