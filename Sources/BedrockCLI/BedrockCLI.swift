import AppleMusicKit
import ArgumentParser
import BedrockService
import BedrockTypes
import Foundation
import Logging
import MCP
import OpenURLKit
import Subprocess

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

    let model: BedrockModel = .claudev3_7_sonnet

    // create Bedrock Tools
    let appleMusicSearchtool = try Tool(
      name: "search_apple_music",
      inputSchema: toolInputSchema(),
      description:
        "This tool searches the Apple Music catalog for songs, albums, and playlists based on the provided input: the artist name and the song or album title.",
    )

    let openURLtool = try Tool(
      name: "open_url",
      inputSchema: openURLToolInputSchema(),
      description:
        "This tool opens a URL in the default web browser. It can be used to open links to websites, articles, or any other online content, including music artwork.",
    )

    // let mcpClient = try await createMCPClient(
    //   name: "MyClientName",
    //   forServer: "SearchAppleMusic"
    // )
    // let (tools, cursor) = try await mcpClient.listTools()
    // print("Tools: \(tools)")

    try await runInteractiveMode(bedrock: bedrock, model: model, tools: [appleMusicSearchtool, openURLtool])
  }

  private func runInteractiveMode(
    bedrock: BedrockService, model: BedrockModel, tools: [BedrockTypes.Tool]
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
        let requestBuilder = try ConverseRequestBuilder(with: model)
          .withPrompt(prompt)
          .withHistory(reply?.getHistory() ?? [])
          .withSystemPrompts(["Your are a music expert. Use tools to search for songs."])
          .withTools(tools)

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

  private func toolInputSchema() throws -> JSON {
    let schema = """
      {
          "type": "object",
          "properties": {
              "artist": {
                  "description": "The artist name to search for",
                  "type": "string"
              },
              "title": {
                  "description": "The song title to search for",
                  "type": "string"
              },
              "storefront": {
                  "description": "Optional Apple Music storefront (default: be)",
                  "type": "string"
              }
          },
          "required": ["artist", "title"]
      }
      """
    return try JSON(from: schema)
  }
  
  private func openURLToolInputSchema() throws -> JSON {
    let schema = """
      {
          "type": "object",
          "properties": {
              "url": {
                  "description": "The URL to open in the default browser",
                  "type": "string"
              }
          },
          "required": ["url"]
      }
      """
    return try JSON(from: schema)
  }

  private func createMCPClient(name: String, forServer: String) async throws -> Client {
    var logger = Logger(label: "BedrockCLI")
    logger.logLevel = .trace
    // Initialize the MCPclient
    let client = Client(name: name, version: "1.0.0")

    let toolConfig = try getMCPToolCommand(for: "SearchAppleMusic")
    let command = toolConfig.command

    let serverInputPipe = Pipe()
    let serverOutputPipe = Pipe()
    let serverInput: FileDescriptor = FileDescriptor(
      rawValue: serverInputPipe.fileHandleForReading.fileDescriptor)
    let serverOutput: FileDescriptor = FileDescriptor(
      rawValue: serverOutputPipe.fileHandleForWriting.fileDescriptor)

    //FIXME: manage the process lifecycle and close the pipes when terminated
    // try serverInput.closeAfter {
    // Start the process before creating the transport
    logger.debug(
      "Launching process",
      metadata: [
        "command": "\(toolConfig.command)",
        "arguments": "\(toolConfig.args.joined(separator: " "))",
      ])
    let pid = try runDetached(.path(FilePath(command)), input: serverInput, output: serverOutput)

    logger.debug("Process launched with PID", metadata: ["pid": "\(pid)"])

    let transport = StdioTransport(
      input: serverInput,
      output: serverOutput,
      logger: logger)
    try await client.connect(transport: transport)
    logger.debug("Connected to MCP server")
    logger.debug("sleeping for 1 second")
    try await Task.sleep(nanoseconds: 1_000_000_000)  // Sleep for 1 second to allow the connection to be established
    logger.debug("done sleeping")
    // Initialize the connection
    let result = try await client.initialize()
    logger.debug("Connection initialized", metadata: ["result": "\(result)"])

    // Wait for the process to finish
    // process.waitUntilExit()
    // print("Process finished with exit code: \(process.terminationStatus)")
    // }

    logger.debug("returning client. How to stop the process ?")
    return client
  }

  /// Reads the mcp.json file in the current directory and returns the command and arguments for a given tool name.
  /// - Parameter toolName: The name of the tool to look up in the mcp.json file
  /// - Returns: A tuple containing the command path and arguments array
  /// - Throws: MCPToolError if the file can't be read or parsed, or if the tool name is not found
  private func getMCPToolCommand(for toolName: String) throws -> MCPConfiguration.ToolConfiguration
  {
    // Get the current directory URL
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let mcpFileURL = currentDirectoryURL.appendingPathComponent("mcp.json")

    // Read the mcp.json file
    do {
      let mcpData = try Data(contentsOf: mcpFileURL)

      // Parse the JSON
      let mcpJSON = try JSONDecoder().decode(MCPConfiguration.self, from: mcpData)

      // Look for the tool
      guard let toolConfig = mcpJSON.mcpServers[toolName] else {
        throw MCPToolError.toolNotFound(name: toolName)
      }

      return toolConfig
    } catch is DecodingError {
      throw MCPToolError.invalidFormat(reason: "JSON structure does not match expected format")
    } catch let error as MCPToolError {
      throw error
    } catch {
      throw MCPToolError.fileNotFound(path: mcpFileURL.path)
    }
  }

  /// Structure representing the MCP configuration file format
  private struct MCPConfiguration: Decodable {
    let mcpServers: [String: ToolConfiguration]

    struct ToolConfiguration: Decodable {
      let command: String
      let args: [String]
    }
  }

  /// Custom error type for MCP tool command operations
  enum MCPToolError: Swift.Error, CustomStringConvertible {
    case fileNotFound(path: String)
    case invalidFormat(reason: String)
    case toolNotFound(name: String)

    var description: String {
      switch self {
      case .fileNotFound(let path):
        return "Could not read MCP configuration file at \(path)"
      case .invalidFormat(let reason):
        return "Invalid MCP configuration format: \(reason)"
      case .toolNotFound(let name):
        return "Tool '\(name)' not found in MCP configuration"
      }
    }
  }
}
