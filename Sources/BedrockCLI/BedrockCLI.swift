import AppleMusicKit
import ArgumentParser
import BedrockService
import Foundation
import Logging
import MCPClientKit
import OpenURLKit

#if canImport(System)
  import System
#endif

/// Extend `Logger.Level` so it can be used as an argument
#if hasFeature(RetroactiveAttribute)
  extension Logger.Level: @retroactive ExpressibleByArgument {}
#else
  extension Logger.Level: ExpressibleByArgument {}
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

  @Option(name: .shortAndLong, help: "Path to temporary credentials file")
  var tempCredentialsPath: String? = nil

  @Option(name: .shortAndLong)
  var logLevel: Logger.Level?

  mutating func run() async throws {

    var logger = Logger(label: "bedrockcli")
    logger.logLevel =
      logLevel ?? ProcessInfo.processInfo.environment["LOG_LEVEL"].flatMap {
        Logger.Level(rawValue: $0)
      } ?? .info
    let auth: BedrockAuthentication
    // first check for temporary credentials
    if let tempCredentialsPath {
      logger.info(
        "Using temporary credentials file", metadata: ["path": .string(tempCredentialsPath)])
      let tempCredentials = try loadAWSCredentials(fromFile: tempCredentialsPath)
      auth = .static(
        accessKey: tempCredentials.accessKeyId, secretKey: tempCredentials.secretAccessKey,
        sessionToken: tempCredentials.sessionToken)
    } else if sso {
      auth = .sso(profileName: profileName ?? "default")
    } else if let profileName {
      auth = .profile(profileName: profileName)
    } else {
      auth = .default
    }

    let bedrock = try await BedrockService(
      region: Region(rawValue: region),
      logger: logger,
      authentication: auth
    )

    // let model: BedrockModel = .nova_lite
    let model: BedrockModel = .claudev3_7_sonnet
    // let model: BedrockModel = .nova_pro

    let mcpFileLocationURL = URL(
      fileURLWithPath:
        "/Users/stormacq/Documents/amazon/code/swift/bedrock/mcp_music_tools")

    let mcpTools: [MCPClient] = try await [MCPClient].create(
      from: mcpFileLocationURL,
      logger: logger
    )

    let tools = try await mcpTools.listTools().joined(separator: "\n")
    logger.trace("Tools discovered:\n\(tools)")

    // start the chat loop
    try await runInteractiveMode(
      bedrock: bedrock, model: model, tools: mcpTools, logger: logger)

    print("Cleaning up...")
    await mcpTools.cleanup()
  }

  private func runInteractiveMode(
    bedrock: BedrockService, model: BedrockModel, tools: [MCPClient], logger: Logger
  ) async throws {

    // verify that the model supports tool usage
    guard model.hasConverseModality(.toolUse) else {
      logger.error("Model does not support converse tools", metadata: ["model": "\(model)"])
      return
    }

    print("Starting interactive chat with \(model.name)...")
    print("Type 'exit' or 'quit' to end the conversation")
    print("-------------------------------------------")

    // variables we're going to reuse for the duration of the conversation
    var messages: History = []
    var requestBuilder: ConverseRequestBuilder? = nil
    // convert MCP Tools to Bedrock Tools
    let bedrockTools = try await tools.bedrockTools()

    // temp for debugging
    // let prompts = [
    //   "What is the release date of the original version of Bohemian Rhapsody by Queen",
    //   "What is its Apple Music ID?",
    //   "exit"
    // ]
    let prompts = [
      "What is the status of the amplifier?",
      "exit",
    ]
    // var i = 0 // set this to 0 to automate the conversation while debugging.
    var i: Int = Int.max  // set this to Int.max to read from stdin
    while true {

      print("\nYou: ", terminator: "")
      var prompt: String = ""
      if i < prompts.count {
        // use the prompt from the array
        prompt = prompts[i]
        i += 1
      } else {
        // read from stdin
        prompt = readLine() ?? ""
      }
      guard prompt.isEmpty == false else { continue }

      if ["exit", "quit"].contains(prompt.lowercased()) {
        break
      }

      print("\nAssistant: ", terminator: "")

      // is it our first request ?
      if requestBuilder == nil {
        requestBuilder = try ConverseRequestBuilder(with: model)
          .withHistory(messages)
          .withPrompt(prompt)
          .withSystemPrompts([
            "Your are a music expert. Use tools to search for songs and artists. Tools allow you to play music in the the house."
          ])
          .withTools(bedrockTools)
      } else {
        // if not, we can just add the prompt to the existing request builder
        requestBuilder = try ConverseRequestBuilder(from: requestBuilder!)
          .withHistory(messages)
          .withPrompt(prompt)
      }

      // add the prompt to the history
      messages.append(.init(prompt))

      // loop on calling the model while the last message is NOT text
      // in other words, has long as we receive toolUse, call the tool, call the model again and iterate until the lats message is text.
      // TODO : how to manage reasoning ?
      var lastMessageIsText = false
      repeat {
        logger.debug("Calling ConverseStream")
        let reply = try await bedrock.converseStream(with: requestBuilder!)
        try await readAndPrintAnswer(reply: reply, messages: &messages, logger: logger)

        // If the last message is toolUse, invoke the tool and
        // continue the conversation with the tool result.
        logger.debug("Have receive a complete message, checking is this is tool use")
        if let msg = messages.last,
          let toolUse = msg.getToolUse()
        {

          logger.trace("Last message", metadata: ["message": "\(msg)"])
          logger.debug("Yes, let's use a tool", metadata: ["toolUse": "\(toolUse.name)"])

          requestBuilder = try await resolveToolUse(
            bedrock: bedrock,
            requestBuilder: requestBuilder!,
            tools: tools,
            toolUse: toolUse,
            messages: &messages,
            logger: logger
          )

          // add the tool result to the history
          if let toolResult = requestBuilder?.toolResult {
            logger.debug("Tool Result", metadata: ["result": "\(toolResult)"])
            messages.append(.init(toolResult))
          } else {
            logger.warning("No tool result found, this is unexpected")
          }

        } else {
          logger.debug("No, checking if the last message is text")
          if messages.last?.hasTextContent() == true {
            lastMessageIsText = true
            logger.debug("yes, exiting the loop and ask next question to the user")
          } else {
            logger.warning("Last message is not text nor tool use, break out the loop")
            logger.debug(
              "Last message", metadata: ["message": "\(String(describing: messages.last))"])
            lastMessageIsText = false
          }
        }
      } while lastMessageIsText == false
    }

    print("\nChat session ended")

  }

  private func readAndPrintAnswer(
    reply: ConverseReplyStream, messages: inout [Message], logger: Logger
  ) async throws {
    for try await element: ConverseStreamElement in reply.stream {

      // read the stream of elements.  If this is a text content, print it.
      // otherwise, collect the message.
      switch element {
      case .text(_, let text):
        print(text, terminator: "")
      case .toolUse(_, let toolUse):
        logger.trace("Tool Use", metadata: ["toolUse": "\(toolUse.name)"])
      case .messageComplete(let message):
        messages.append(message)
        print("\n")
      case .metaData(let metadata):
        logger.trace("Metadata", metadata: ["metadata": "\(metadata)"])
      default:
        break
      }
    }
  }

  private func resolveToolUse(
    bedrock: BedrockService,
    requestBuilder: ConverseRequestBuilder,
    tools: [MCPClient],
    toolUse: ToolUseBlock,
    messages: inout History,
    logger: Logger
  ) async throws -> ConverseRequestBuilder {

    guard let message = messages.last else {
      fatalError(
        "No last message found in the history to resolve tool use"
      )
    }

    // convert swift-bedrock-library's input to a MCP swift-sdk [String: Value]?
    let mcpToolInput = try toolUse.input.toMCPInput()

    // log the tool use
    logger.trace("Tool Use", metadata: ["name": "\(toolUse.name)", "input": "\(mcpToolInput)"])

    // invoke the tool
    let textResult = try await tools.callTool(
      name: toolUse.name, arguments: mcpToolInput, logger: logger)
    logger.trace("Tool Result", metadata: ["result": "\(textResult)"])

    // pass the result back to the model
    return try ConverseRequestBuilder(from: requestBuilder, with: message)
      .withToolResult(textResult)
  }

  enum CredentialsError: Error {
    case fileNotFound(String)
    case invalidData(String)
    case decodingError(Error)
    case credentialsExpired(Date, Date)  // Includes expiration date and current date for context
  }
  func loadAWSCredentials(fromFile path: String) throws -> AWSTemporaryCredentials {
    let fileManager = FileManager.default

    // Check if file exists
    guard fileManager.fileExists(atPath: path) else {
      throw CredentialsError.fileNotFound("Credentials file not found at path: \(path)")
    }

    // Read file data
    guard let data = fileManager.contents(atPath: path) else {
      throw CredentialsError.invalidData("Could not read data from file: \(path)")
    }

    // Decode JSON into AWSTemporaryCredentials
    let credentials: AWSTemporaryCredentials
    do {
      let decoder = JSONDecoder()
      credentials = try decoder.decode(AWSTemporaryCredentials.self, from: data)
    } catch {
      throw CredentialsError.decodingError(error)
    }
    // Verify credentials haven't expired
    let currentDate = Date()
    if currentDate >= credentials.expiration {
      throw CredentialsError.credentialsExpired(credentials.expiration, currentDate)
    }
    return credentials
  }
}

extension Array where Element == MCPClient {

  // return an array of Bedrock Tool structure for each MCP Client Tool
  func bedrockTools() async throws -> [Tool] {
    var bedrockTools: [Tool] = []
    for mcpClient in self {
      let mcpTools = try await mcpClient.client.listTools()
      bedrockTools.append(
        contentsOf: mcpTools.tools.compactMap {
          try? Tool(
            name: $0.name, inputSchema: JSON(from: $0.inputSchema),
            description: $0.description)
        })
    }
    return bedrockTools
  }

}

extension JSON {
  // this method converts a Codable representation of JSON as expressed in the MCP swift-sdk
  // to a JSON object that can be used in the BedrockService.Tool
  // Source : https://github.com/modelcontextprotocol/swift-sdk/blob/main/Sources/MCP/Base/Value.swift
  // Destination : https://github.com/sebsto/swift-bedrock-library/blob/main/Sources/BedrockService/Converse/JSON.swift
  // MCPValue is a vended type from the MCP swift-sdk
  init(from value: MCPValue?) throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(value)
    self = try JSON(from: data)
  }

  // convert this JSON object to the format expected by the MCP swift-sdk library
  func toMCPInput() throws -> [String: MCPValue] {
    let encoder = JSONEncoder()
    let data = try encoder.encode(self)
    let decoder = JSONDecoder()
    let result = try decoder.decode([String: MCPValue].self, from: data)
    return result
  }
}
