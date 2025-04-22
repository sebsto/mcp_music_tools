import AppleMusicKit
import ArgumentParser
import BedrockService
import BedrockTypes
import Foundation
import Logging
import MCPClientKit
import OpenURLKit

#if canImport(System)
  import System
#endif

@main
struct BedrockCLI: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "bedrock",
    abstract: "A command-line tool for interacting with Amazon Bedrock"
  )

  @Option(name: .shortAndLong, help: "AWS region to use")
  var region: String = "us-east-1"

  @Flag(name: .shortAndLong, help: "Use SSO authentication (default: false)")
  var sso: Bool = false

  @Option(
    name: .shortAndLong,
    help: "The name of the profile to use. Use the default resolver chain when nil")
  var profileName: String? = nil

  mutating func run() async throws {

    var logger = Logger(label: "com.example.bedrockcli")
    logger.logLevel = .trace

    let auth: BedrockAuthentication
    if sso {
      auth = .sso(profileName: profileName ?? "default")
    } else if let profileName {
      auth = .profile(profileName: profileName)
    } else {
      auth = .default
    }

    let bedrock = try await BedrockService(
      region: Region(rawValue: region),
      authentication: auth
    )

    let model: BedrockModel = .nova_pro

    let mcpFileURL = URL(
      fileURLWithPath:
        "/Users/stormacq/Documents/amazon/code/swift/bedrock/mcp_music_tools/mcp.json")

    var mcpTools: [MCPClient] = []
    let mcpSearchAppleMusic = try await MCPClient(
      with: mcpFileURL,
      name: "BedrockCLI-SearchAppleMusic",
      for: "SearchAppleMusic",
      logger: logger
    )
    let mcpOpenURL = try await MCPClient(
      with: mcpFileURL,
      name: "BedrockCLI-OpenURL",
      for: "OpenURL",
      logger: logger
    )
    mcpTools.append(contentsOf: [mcpSearchAppleMusic, mcpOpenURL])

    // let tools = try await mcpTools.listTools().joined(separator: "\n")
    // print("\(tools)")

    try await runInteractiveMode(
      bedrock: bedrock, model: model, tools: mcpTools)

    print("Cleaning up...")
    await mcpTools.cleanup()
  }

  private func runInteractiveMode(
    bedrock: BedrockService, model: BedrockModel, tools: [MCPClient]
  )
    async throws
  {

    // verify that the model supports tool usage
    guard model.hasConverseModality(.toolUse) else {
      print("\(model.name) does not support converse tools")
      return
    }

    print("Starting interactive chat with \(model.name)...")
    print("Type 'exit' or 'quit' to end the conversation")
    print("-------------------------------------------")

    // variables we're going to reuse for the duration of the conversation
    var reply: ConverseReply? = nil

    while true {
      print("\nYou: ", terminator: "")
      let prompt: String = readLine() ?? ""
      guard prompt.isEmpty == false else { continue }

      if ["exit", "quit"].contains(prompt.lowercased()) {
        break
      }

      do {
        // convert MCP Tools to Bedrock Tools
        let bedrockTools = try await tools.bedrockTools()
        let requestBuilder = try ConverseRequestBuilder(with: model)
          .withPrompt(prompt)
          .withHistory(reply?.getHistory() ?? [])
          .withSystemPrompts(["Your are a music expert. Use tools to search for songs."])
          .withTools(bedrockTools)

        reply = try await bedrock.converse(with: requestBuilder)

        // loop on tool usage until we get a non-tool use reply
        while let toolUse = try? reply?.getToolUse() {
          try await resolveToolUse(
            bedrock: bedrock,
            requestBuilder: requestBuilder,
            toolUse: toolUse,
            reply: &reply!
          )
        }

        print("\nAssistant: \(reply!)")

      } catch {
        print("Error: \(error.localizedDescription)")
      }
    }
    print("\nChat session ended")
  }

  private func resolveToolUse(
    bedrock: BedrockService,
    requestBuilder: ConverseRequestBuilder,
    toolUse: ToolUseBlock,
    reply: inout ConverseReply
  ) async throws {
    print("\nTool Use: \(toolUse.name)")

    // Dispatch to the correct tool based on the tool name
    var toolResult: any Codable

    switch toolUse.name {
    case "search_apple_music":
      toolResult = try await handleAppleMusicSearch(toolUse: toolUse)
    case "open_url":
      toolResult = try await handleOpenURL(toolUse: toolUse)
    default:
      print("Unknown tool: \(toolUse.name)")
      return
    }

    print("Received response from tool")

    let nextRequestBuilder = try ConverseRequestBuilder(from: requestBuilder, with: reply)
      .withToolResult(toolResult)

    reply = try await bedrock.converse(with: nextRequestBuilder)
  }

  /// Handles the Apple Music search tool
  /// - Parameter toolUse: The tool use block containing input parameters
  /// - Returns: The search response
  private func handleAppleMusicSearch(toolUse: ToolUseBlock) async throws -> SearchResponse {
    let artist: String = toolUse.input["artist"] ?? ""
    let title: String = toolUse.input["title"] ?? ""
    let storefront: String = toolUse.input["storefront"] ?? "be"

    // Create an AppleMusicClient client with default token generation from AppleMusicKit
    let client = try await AppleMusicClient(storefront: storefront)
    return try await client.searchByArtistAndTitle(artist: artist, title: title)
  }

  /// Handles the open URL tool
  /// - Parameter toolUse: The tool use block containing input parameters
  /// - Returns: A confirmation message
  private func handleOpenURL(toolUse: ToolUseBlock) async throws -> String {
    guard let urlString: String = toolUse.input["url"] else {
      throw URLOpenerError.invalidURL
    }

    try URLOpener.open(urlString)
    return "Successfully opened URL: \(urlString)"
  }
}

extension Array where Element == MCPClient {

  // return an array of Bedrock Tool structure for each MCP Client Tool
  func bedrockTools() async throws -> [BedrockTypes.Tool] {
    var bedrockTools: [BedrockTypes.Tool] = []
    for mcpClient in self {
      let mcpTools = try await mcpClient.client.listTools()
      bedrockTools.append(
        contentsOf: mcpTools.tools.compactMap {
          try? BedrockTypes.Tool(
            name: $0.name, inputSchema: inputSchemaFromValue($0.inputSchema),
            description: $0.description)
        })
    }
    return bedrockTools
  }

  private func inputSchemaFromValue(_ value: Encodable) throws -> JSON {
    let encoder = JSONEncoder()
    let data = try encoder.encode(value)
    return try JSON(from: data)
  }
}
