import ArgumentParser
import AppleMailExporter
import Foundation

@main
struct AppleMailExporterCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "apple-mail-exporter",
        abstract: "Search and export emails from Apple Mail's local database.",
        discussion: "Run with no arguments for interactive mode.",
        version: appVersion
    )

    @Argument(help: "Keywords to search (subject, sender address, sender name).")
    var keywords: [String] = []

    @Option(name: [.short, .long], help: "Output directory (default: output).")
    var output: String = "output"

    @Option(name: [.short, .long], help: "Max number of emails to export (0 = all).")
    var limit: Int = 0

    @Flag(name: .long, help: "Just list matching emails without exporting.")
    var listOnly: Bool = false

    @Flag(name: [.short, .customLong("interactive")], help: "Run in interactive mode.")
    var interactiveMode: Bool = false

    @Option(name: .customLong("mail-dir"), help: "Override the Mail V* directory.")
    var mailDir: String?

    @Option(name: .customLong("mail-base"), help: "Override the Mail base directory.")
    var mailBase: String?

    func run() throws {
        let mailDirURL = mailDir.map { URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath) }
        let mailBaseURL = mailBase.map { URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath) }

        if interactiveMode || keywords.isEmpty {
            runInteractive(mailDir: mailDirURL, mailBase: mailBaseURL)
            return
        }

        let results = try listMatches(
            keywords: keywords, limit: limit,
            mailDir: mailDirURL, mailBase: mailBaseURL
        )

        print("\nSearching for: \(keywords.joined(separator: ", "))")
        print("Found \(results.count) matching emails.\n")

        guard !results.isEmpty else { return }

        if listOnly {
            printEmailList(results)
            return
        }

        let exported = try runExport(
            keywords: keywords, output: output, limit: limit,
            mailDir: mailDirURL, mailBase: mailBaseURL
        )

        for path in exported {
            let name = path.lastPathComponent
            let parts = name.split(separator: "_", maxSplits: 2)
            let date = parts.count > 1 ? String(parts[1]) : ""
            print("  [\(date)] \(name)")
        }

        let outputPath = (output as NSString).expandingTildeInPath
        print("\nExported \(exported.count) emails to \(outputPath)\n")
    }
}

func printEmailList(_ results: [EmailRecord]) {
    for (i, msg) in results.enumerated() {
        let date = String(normalizeTimestamp(msg.dateSentRaw).prefix(10))
        let sender = msg.senderName ?? msg.senderAddress ?? "?"
        let subject = msg.subject ?? "?"
        print("  \(String(format: "%3d", i + 1)). [\(date)] \(sender): \(subject)")
    }
}

func printPreview(_ results: [EmailRecord], limit: Int = 10) {
    let previewCount = min(limit, results.count)
    for (i, msg) in results.prefix(previewCount).enumerated() {
        let date = String(normalizeTimestamp(msg.dateSentRaw).prefix(10))
        let sender = msg.senderName ?? msg.senderAddress ?? "?"
        let subject = String((msg.subject ?? "?").prefix(65))
        print("  \(String(format: "%3d", i + 1)). [\(date)] \(sender): \(subject)")
    }
    if results.count > previewCount {
        print("  ... and \(results.count - previewCount) more")
    }
}
