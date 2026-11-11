# apple-mail-exporter

A Swift CLI that searches the local Apple Mail database and exports matched mail to Markdown. It ships through `aayush9029/tap`. Status: shipped.

## Commands

| Task | Command |
|------|---------|
| Build | `swift build` |
| Test | `swift test` |
| Universal release build | `swift build -c release --arch arm64 --arch x86_64` |

## Architecture

- `Sources/CLI` holds the argument parser and the interactive mode.
- `Sources/AppleMailExporter` reads the Mail SQLite index (`Database.swift`), parses `.emlx` files, and writes Markdown.
- `Sources/CSQLite` wraps the system SQLite library.

## Rules

- The tool needs Full Disk Access for the terminal. Tests do not touch the real Mail data.
- Release: push a `v*` tag. `.github/workflows/release.yml` builds the universal binary and attaches `apple-mail-exporter-<version>-macos-universal.tar.gz` to the GitHub release. Point the tap formula `url` at that archive.
- Update `Sources/AppleMailExporter/Version.swift` before you tag.
