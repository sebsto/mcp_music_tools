import AmplifierKit
import MCP
import MCPServerKit
import ToolMacro

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// Common input structure for amplifier commands
@SchemaDefinition
public struct AmplifierInput: Codable {
    /// Optional host address for the amplifier (default: 192.168.1.37)
    let host: String?
    /// Optional port for the amplifier (default: 10443)
    let port: Int?
}

@Tool(
    name: "powerOn",
    description: "Power on the amplifier",
    schema: AmplifierInput.self
)
public struct PowerOnTool: ToolProtocol {
    public typealias Input = AmplifierInput
    public typealias Output = String

    public func handle(input: AmplifierInput) async throws -> String {
        let config = AmplifierConfig(
            host: input.host ?? "192.168.1.37",
            port: input.port ?? 10443
        )
        let controller = HTTPAmplifierController(config: config)

        try await controller.powerOn()
        return "Amplifier powered on"
    }
}

@Tool(
    name: "powerOff",
    description: "Power off the amplifier",
    schema: AmplifierInput.self
)
public struct PowerOffTool: ToolProtocol {
    public typealias Input = AmplifierInput
    public typealias Output = String

    public func handle(input: AmplifierInput) async throws -> String {
        let config = AmplifierConfig(
            host: input.host ?? "192.168.1.37",
            port: input.port ?? 10443
        )
        let controller = HTTPAmplifierController(config: config)

        try await controller.powerOff()
        return "Amplifier powered off"
    }
}

@Tool(
    name: "switchToSonos",
    description: "Switch amplifier input to Sonos",
    schema: AmplifierInput.self
)
public struct SwitchToSonosTool: ToolProtocol {
    public typealias Input = AmplifierInput
    public typealias Output = String

    public func handle(input: AmplifierInput) async throws -> String {
        let config = AmplifierConfig(
            host: input.host ?? "192.168.1.37",
            port: input.port ?? 10443
        )
        let controller = HTTPAmplifierController(config: config)

        try await controller.switchToSonos()
        return "Switched to Sonos input"
    }
}

@Tool(
    name: "switchToAppleTV",
    description: "Switch amplifier input to Apple TV",
    schema: AmplifierInput.self
)
public struct SwitchToAppleTVTool: ToolProtocol {
    public typealias Input = AmplifierInput
    public typealias Output = String

    public func handle(input: AmplifierInput) async throws -> String {
        let config = AmplifierConfig(
            host: input.host ?? "192.168.1.37",
            port: input.port ?? 10443
        )
        let controller = HTTPAmplifierController(config: config)

        try await controller.switchToAppleTV()
        return "Switched to Apple TV input"
    }
}

// Input structure for switchToSource
@SchemaDefinition
public struct SwitchToSourceInput: Codable {
    /// Source index (1-based)
    let index: Int
    /// Optional host address for the amplifier (default: 192.168.1.37)
    let host: String?
    /// Optional port for the amplifier (default: 10443)
    let port: Int?
}

@Tool(
    name: "switchToSource",
    description: "Switch amplifier to a specific input source by index",
    schema: SwitchToSourceInput.self
)
public struct SwitchToSourceTool: ToolProtocol {
    public typealias Input = SwitchToSourceInput
    public typealias Output = String

    public func handle(input: SwitchToSourceInput) async throws -> String {
        let config = AmplifierConfig(
            host: input.host ?? "192.168.1.37",
            port: input.port ?? 10443
        )
        let controller = HTTPAmplifierController(config: config)

        try await controller.switchToSource(index: input.index)
        return "Switched to source with index \(input.index)"
    }
}

@Tool(
    name: "getSources",
    description: "Get a list of available input sources",
    schema: AmplifierInput.self
)
public struct GetSourcesTool: ToolProtocol {
    public typealias Input = AmplifierInput
    public typealias Output = String

    public func handle(input: AmplifierInput) async throws -> String {
        let config = AmplifierConfig(
            host: input.host ?? "192.168.1.37",
            port: input.port ?? 10443
        )
        let controller = HTTPAmplifierController(config: config)

        let sources = try await controller.getSourceNames()

        // Convert sources to JSON with indices
        var sourcesWithIndices: [[String: Any]] = []
        for (index, source) in sources.enumerated() {
            sourcesWithIndices.append([
                "index": index + 1,
                "name": source,
            ])
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // Convert to JSON string
        let jsonData = try JSONSerialization.data(
            withJSONObject: sourcesWithIndices,
            options: [.prettyPrinted, .sortedKeys]
        )
        return String(decoding: jsonData, as: UTF8.self)
    }
}

@Tool(
    name: "getStatus",
    description: "Get the current status of the amplifier",
    schema: AmplifierInput.self
)
public struct GetStatusTool: ToolProtocol {
    public typealias Input = AmplifierInput
    public typealias Output = String

    public func handle(input: AmplifierInput) async throws -> String {
        let config = AmplifierConfig(
            host: input.host ?? "192.168.1.37",
            port: input.port ?? 10443
        )
        let controller = HTTPAmplifierController(config: config)

        let status = try await controller.getMainZoneStatus()

        // Convert status to JSON
        let statusDict: [String: Any] = [
            "zone": status.name,
            "power": status.isPowered ? "On" : "Off",
            "source": status.sourceName ?? "Unknown",
        ]

        // Convert to JSON string
        let jsonData = try JSONSerialization.data(
            withJSONObject: statusDict,
            options: [.prettyPrinted, .sortedKeys]
        )
        return String(decoding: jsonData, as: UTF8.self)
    }
}