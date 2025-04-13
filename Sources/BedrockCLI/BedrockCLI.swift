import AppleMusicKit
import ArgumentParser
import BedrockService
import BedrockTypes
import Foundation

@main
struct BedrockCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bedrock",
        abstract: "A command-line tool for interacting with Amazon Bedrock"
    )

    @Option(name: .shortAndLong, help: "AWS region to use")
    var region: String = "us-east-1"

    @Option(name: .shortAndLong, help: "AWS SSO profile name to use (enables SSO authentication)")
    var sso: String?

    // can I use the Region iitializer here ?
    func getRegion() -> Region {
        switch region.lowercased() {
        case "us-east-1":
            return .useast1
        case "us-west-1":
            return .uswest1
        case "us-west-2":
            return .uswest2
        case "eu-central-1":
            return .eucentral1
        case "ap-northeast-1":
            return .apnortheast1
        case "ap-southeast-1":
            return .apsoutheast1
        case "ap-southeast-2":
            return .apsoutheast2
        default:
            return .useast1
        }
    }

    mutating func run() async throws {
        let bedrock = try await BedrockService(
            region: getRegion(),
            useSSO: sso != nil,
            ssoProfileName: sso ?? "default"
        )

        // examples in the readme doesn't compile
        let model: BedrockModel = .claudev3_7_sonnet

        // create a Tool
        let tool = Tool(
            name: "search_apple_music",
            inputSchema: toolInputSchema(),
            description:
                "This tool searches the Apple Music catalog for songs, albums, and playlists based on the provided input: the artist name and the song or album title.",
        )

        try await runInteractiveMode(bedrock: bedrock, model: model, tools: [tool])
    }

    private func runInteractiveMode(bedrock: BedrockService, model: BedrockModel, tools: [Tool])
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

        var conversation: [Message] = []

        while true {
            print("\nYou: ", terminator: "")
            guard let input = readLine(), !input.isEmpty else { continue }

            if ["exit", "quit"].contains(input.lowercased()) {
                break
            }

            do {
                let reply = try await bedrock.converse(
                    with: model,
                    prompt: input,
                    history: conversation,
                    tools: tools,
                )
                conversation += reply.history
                print("\nAssistant: \(reply)")

                if reply.hasToolUse() {
                    let toolUse = try reply.getToolUse()
                    print("\nTool Use: \(toolUse.name)")
                    // print("Input: \(toolUse.input)")

                    let input = toolUse.input.value as? [String: JSON]
                    let artist: String = (input?["artist"] as? JSON)?.value as! String
                    let title: String = (input?["title"] as? JSON)?.value as! String

                    // // Use default token generation from AppleMusicKit
                    let client = try await AppleMusicClient(storefront: "be")
                    let results = try await client.searchByArtistAndTitle(
                        artist: artist, title: title)

                    let resultData = try JSONEncoder().encode(results)
                    let resultJSON = try JSONDecoder().decode(JSON.self, from: resultData)
                    let toolResult = ToolResultBlock(resultJSON, id: toolUse.id)

                    // let message = Message(toolResult)
                    // conversation.append(message)

                    let reply = try await bedrock.converse(
                        with: model,
                        history: conversation,
                        tools: tools,
                        toolResult: toolResult
                    )
                    conversation += reply.history
                    print("\nAssistant: \(reply)")

                }

            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }

        print("\nChat session ended")
    }

    private func toolInputSchema() -> JSON {
        // JSON([
        //     "type": "object",
        //     "properties": [
        //         "artist": [
        //             "description": "The artist name to search for",
        //             "type": "string",
        //         ],
        //         "title": [
        //             "description": "The song title to search for",
        //             "type": "string",
        //         ],
        //         "storefront": [
        //             "description": "Optional Apple Music storefront (default: fr)",
        //             "type": "string",
        //         ],
        //     ],
        //     "required": ["artist", "title"],
        // ])

        // would be great to have a constructor that accepts a JSON string
        //and show it in the readme
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
        return try! JSONDecoder().decode(JSON.self, from: schema.data(using: .utf8)!)
    }
}
