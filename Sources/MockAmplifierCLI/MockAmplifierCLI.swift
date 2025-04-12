import AmplifierKit
import ArgumentParser
import Foundation

@main
struct MockAmplifierCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "MockAmplifierCLI",
        abstract: "Test the amplifier CLI with a mock controller",
        subcommands: [
            Status.self,
        ]
    )

    struct Status: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "status",
            abstract: "Get amplifier status"
        )

        func run() async throws {
            let controller = MockAmplifierController()
            
            // Set up some test data
            controller.isPowered = true
            controller.currentSource = "Sonos"
            controller.zoneName = "MAIN ZONE"
            
            let status = try await controller.getMainZoneStatus()
            print("Zone: \(status.name)")
            print("Power: \(status.isPowered ? "On" : "Off")")
            if let sourceName = status.sourceName {
                print("Current Source: \(sourceName)")
            }
        }
    }
}
