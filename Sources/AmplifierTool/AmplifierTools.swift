import AmplifierKit
import MCP
import MCPServerKit

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

// Common input structure for amplifier commands
struct AmplifierInput: Codable {
  let host: String?
  let port: Int?
}

// Power On Tool
let powerOnToolSchema = """
  {
      "type": "object",
      "properties": {
          "host": {
              "description": "Optional host address for the amplifier (default: 192.168.1.37)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the amplifier (default: 10443)",
              "type": "integer"
          }
      }
  }
  """

let powerOnTool = MCPTool<AmplifierInput, String>(
  name: "powerOn",
  description: "Power on the amplifier",
  inputSchema: powerOnToolSchema,
  converter: { params in
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return AmplifierInput(
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
    let config = AmplifierConfig(
      host: input.host ?? "192.168.1.37",
      port: input.port ?? 10443
    )
    let controller = HTTPAmplifierController(config: config)

    try await controller.powerOn()
    return "Amplifier powered on"
  }
)

// Power Off Tool
let powerOffToolSchema = """
  {
      "type": "object",
      "properties": {
          "host": {
              "description": "Optional host address for the amplifier (default: 192.168.1.37)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the amplifier (default: 10443)",
              "type": "integer"
          }
      }
  }
  """

let powerOffTool = MCPTool<AmplifierInput, String>(
  name: "powerOff",
  description: "Power off the amplifier",
  inputSchema: powerOffToolSchema,
  converter: { params in
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return AmplifierInput(
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
    let config = AmplifierConfig(
      host: input.host ?? "192.168.1.37",
      port: input.port ?? 10443
    )
    let controller = HTTPAmplifierController(config: config)

    try await controller.powerOff()
    return "Amplifier powered off"
  }
)

// Switch to Sonos Tool
let switchToSonosToolSchema = """
  {
      "type": "object",
      "properties": {
          "host": {
              "description": "Optional host address for the amplifier (default: 192.168.1.37)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the amplifier (default: 10443)",
              "type": "integer"
          }
      }
  }
  """

let switchToSonosTool = MCPTool<AmplifierInput, String>(
  name: "switchToSonos",
  description: "Switch amplifier input to Sonos",
  inputSchema: switchToSonosToolSchema,
  converter: { params in
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return AmplifierInput(
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
    let config = AmplifierConfig(
      host: input.host ?? "192.168.1.37",
      port: input.port ?? 10443
    )
    let controller = HTTPAmplifierController(config: config)

    try await controller.switchToSonos()
    return "Switched to Sonos input"
  }
)

// Switch to Apple TV Tool
let switchToAppleTVToolSchema = """
  {
      "type": "object",
      "properties": {
          "host": {
              "description": "Optional host address for the amplifier (default: 192.168.1.37)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the amplifier (default: 10443)",
              "type": "integer"
          }
      }
  }
  """

let switchToAppleTVTool = MCPTool<AmplifierInput, String>(
  name: "switchToAppleTV",
  description: "Switch amplifier input to Apple TV",
  inputSchema: switchToAppleTVToolSchema,
  converter: { params in
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return AmplifierInput(
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
    let config = AmplifierConfig(
      host: input.host ?? "192.168.1.37",
      port: input.port ?? 10443
    )
    let controller = HTTPAmplifierController(config: config)

    try await controller.switchToAppleTV()
    return "Switched to Apple TV input"
  }
)

// Switch to Source Tool
struct SwitchToSourceInput: Codable {
  let index: Int
  let host: String?
  let port: Int?
}

let switchToSourceToolSchema = """
  {
      "type": "object",
      "properties": {
          "index": {
              "description": "Source index (1-based)",
              "type": "integer",
              "minimum": 1
          },
          "host": {
              "description": "Optional host address for the amplifier (default: 192.168.1.37)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the amplifier (default: 10443)",
              "type": "integer"
          }
      },
      "required": ["index"]
  }
  """

let switchToSourceTool = MCPTool<SwitchToSourceInput, String>(
  name: "switchToSource",
  description: "Switch amplifier to a specific input source by index",
  inputSchema: switchToSourceToolSchema,
  converter: { params in
    let index = try MCPTool<Int, Int>.extractParameter(params, name: "index")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return SwitchToSourceInput(
      index: index,
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
    let config = AmplifierConfig(
      host: input.host ?? "192.168.1.37",
      port: input.port ?? 10443
    )
    let controller = HTTPAmplifierController(config: config)

    try await controller.switchToSource(index: input.index)
    return "Switched to source with index \(input.index)"
  }
)

// Get Sources Tool
let getSourcesToolSchema = """
  {
      "type": "object",
      "properties": {
          "host": {
              "description": "Optional host address for the amplifier (default: 192.168.1.37)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the amplifier (default: 10443)",
              "type": "integer"
          }
      }
  }
  """

let getSourcesTool = MCPTool<AmplifierInput, String>(
  name: "getSources",
  description: "Get a list of available input sources",
  inputSchema: getSourcesToolSchema,
  converter: { params in
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return AmplifierInput(
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
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
      withJSONObject: sourcesWithIndices, options: [.prettyPrinted, .sortedKeys])
    return String(decoding: jsonData, as: UTF8.self)
  }
)

// Get Status Tool
let getStatusToolSchema = """
  {
      "type": "object",
      "properties": {
          "host": {
              "description": "Optional host address for the amplifier (default: 192.168.1.37)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the amplifier (default: 10443)",
              "type": "integer"
          }
      }
  }
  """

let getStatusTool = MCPTool<AmplifierInput, String>(
  name: "getStatus",
  description: "Get the current status of the amplifier",
  inputSchema: getStatusToolSchema,
  converter: { params in
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return AmplifierInput(
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
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
      withJSONObject: statusDict, options: [.prettyPrinted, .sortedKeys])
    return String(decoding: jsonData, as: UTF8.self)
  }
)
