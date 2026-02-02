import Foundation
import AppleMailExporter

func runInteractive(mailDir: URL?, mailBase: URL?) {
    print(String(repeating: "=", count: 50))
    print("  Apple Mail Email Exporter (interactive)")
    print(String(repeating: "=", count: 50))
    print()
    print("  Type comma-separated keywords to search.")
    print("  Commands:  q/quit  = exit")
    print("             help    = show usage")
    print()

    while true {
        print("keywords> ", terminator: "")
        guard let raw = readLine()?.trimmingCharacters(in: .whitespaces) else {
            print("\nBye!")
            break
        }

        if raw.isEmpty { continue }

        let lower = raw.lowercased()
        if lower == "q" || lower == "quit" || lower == "exit" {
            print("Bye!")
            break
        }
        if lower == "help" {
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
        }

        let keywords = raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if keywords.isEmpty {
            print("  No keywords entered.\n")
            continue
        }

        do {
            let results = try listMatches(keywords: keywords, mailDir: mailDir, mailBase: mailBase)
            print("\n  Found \(results.count) emails.\n")

            if results.isEmpty { continue }

            printPreview(results)
            print()

            print("  [e]xport / [l]ist all / [s]kip? (e/l/s) ", terminator: "")
            guard let action = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() else {
                print("\nBye!")
                break
            }

            if action == "s" || action == "skip" || action.isEmpty {
                print()
                continue
            }

            if action == "l" || action == "list" {
                printEmailList(results)
                print()
                continue
            }

            if action == "e" || action == "export" {
                let defaultFolder = "output/" + sanitizeFilename(keywords[0].lowercased())
                print("  Output folder [\(defaultFolder)]: ", terminator: "")
                let folderInput = readLine()?.trimmingCharacters(in: .whitespaces) ?? ""
                let folder = folderInput.isEmpty ? defaultFolder : folderInput

                print("  Max emails (0 = all) [0]: ", terminator: "")
                let limitInput = readLine()?.trimmingCharacters(in: .whitespaces) ?? ""
                let limit = Int(limitInput) ?? 0

                let exported = try runExport(
                    keywords: keywords, output: folder, limit: limit,
                    mailDir: mailDir, mailBase: mailBase
                )
                print("\nExported \(exported.count) emails to \(folder)/\n")
            }
        } catch {
            print("  Error: \(error.localizedDescription)\n")
        }
    }
}
