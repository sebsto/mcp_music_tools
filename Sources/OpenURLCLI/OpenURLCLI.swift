import ArgumentParser
import Foundation
import OpenURLKit

@main
struct OpenURLCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "OpenURLCLI",
        abstract: "Open URLs in the default browser",
        subcommands: [
            Open.self
        ],
        defaultSubcommand: Open.self
    )

    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "open",
            abstract: "Open a URL in the default browser"
        )

        @Argument(help: "The URL to open (e.g., https://aws.amazon.com)")
        var url: String

        func run() throws {
            do {
                try URLOpener.open(url)
                print("Opening URL: \(url)")
            } catch URLOpenerError.invalidURL {
                print("Error: Invalid URL format")
                throw ExitCode.failure
            } catch URLOpenerError.failedToOpenURL {
                print("Error: Failed to open URL in browser")
                throw ExitCode.failure
            } catch URLOpenerError.unsupportedPlatform {
                print("Error: URL opening is not supported on this platform")
                throw ExitCode.failure
            } catch {
                print("Error: \(error.localizedDescription)")
                throw ExitCode.failure
            }
        }
    }
}
