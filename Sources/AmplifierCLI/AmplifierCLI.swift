import AmplifierKit
import ArgumentParser
import Foundation

@main
struct AmplifierCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "AmplifierCLI",
        abstract: "Control your amplifier from the command line",
        subcommands: [
            PowerOn.self,
            PowerOff.self,
            SwitchToSonos.self,
            SwitchToAppleTV.self,
            SwitchToSource.self,
            GetSources.self,
            Status.self,
        ]
    )

    struct Options: ParsableArguments {
        @Option(name: .long, help: "Amplifier host address")
        var host: String = "192.168.1.37"

        @Option(name: .long, help: "Amplifier port")
        var port: Int = 10443
    }

    struct PowerOn: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "power-on",
            abstract: "Power on the amplifier"
        )

        @OptionGroup var options: Options

        func run() async throws {
            let config = AmplifierConfig(host: options.host, port: options.port)
            let controller = HTTPAmplifierController(config: config)
            try await controller.powerOn()
            print("Amplifier powered on")
        }
    }

    struct PowerOff: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "power-off",
            abstract: "Power off the amplifier"
        )

        @OptionGroup var options: Options

        func run() async throws {
            let config = AmplifierConfig(host: options.host, port: options.port)
            let controller = HTTPAmplifierController(config: config)
            try await controller.powerOff()
            print("Amplifier powered off")
        }
    }

    struct SwitchToSonos: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "sonos",
            abstract: "Switch input to Sonos"
        )

        @OptionGroup var options: Options

        func run() async throws {
            let config = AmplifierConfig(host: options.host, port: options.port)
            let controller = HTTPAmplifierController(config: config)
            try await controller.switchToSonos()
            print("Switched to Sonos input")
        }
    }

    struct SwitchToAppleTV: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "appletv",
            abstract: "Switch input to Apple TV"
        )

        @OptionGroup var options: Options

        func run() async throws {
            let config = AmplifierConfig(host: options.host, port: options.port)
            let controller = HTTPAmplifierController(config: config)
            try await controller.switchToAppleTV()
            print("Switched to Apple TV input")
        }
    }

    struct SwitchToSource: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "source",
            abstract: "Switch to a specific input source by index"
        )

        @OptionGroup var options: Options
        
        @Argument(help: "Source index (1-based)")
        var index: Int

        func run() async throws {
            let config = AmplifierConfig(host: options.host, port: options.port)
            let controller = HTTPAmplifierController(config: config)
            try await controller.switchToSource(index: index)
            print("Switched to source with index \(index)")
        }
    }

    struct GetSources: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "sources",
            abstract: "List available input sources"
        )

        @OptionGroup var options: Options

        func run() async throws {
            let config = AmplifierConfig(host: options.host, port: options.port)
            let controller = HTTPAmplifierController(config: config)
            let sources = try await controller.getSourceNames()
            print("Available sources:")
            for (index, source) in sources.enumerated() {
                print("- \(index + 1): \(source)")
            }
        }
    }

    struct Status: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "status",
            abstract: "Get amplifier status"
        )

        @OptionGroup var options: Options

        func run() async throws {
            let config = AmplifierConfig(host: options.host, port: options.port)
            let controller = HTTPAmplifierController(config: config)
            let status = try await controller.getMainZoneStatus()
            print("Zone: \(status.name)")
            print("Power: \(status.isPowered ? "On" : "Off")")
        }
    }
}
