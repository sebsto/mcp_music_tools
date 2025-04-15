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

    @Flag(name: .shortAndLong, help: "Use SSO authentication (default: false)")
    var sso: Bool  = false

    @Option(name: .shortAndLong, help: "The name of the profile to use (default: default)")
    var profileName: String = "default"

    mutating func run() async throws {
        let bedrock = try await BedrockService(
            region: Region(rawValue: region),
            useSSO: sso,
            profileName: profileName
        )

        // examples in the readme doesn't compile
        let model: BedrockModel = .claudev3_7_sonnet

        // create a Tool
        let tool = try Tool(
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
            var prompt: String? = readLine()
            guard prompt?.isEmpty == false else { continue }

            if ["exit", "quit"].contains(prompt?.lowercased()) {
                break
            }

            var toolResult: ToolResultBlock? = nil

            do {
                let reply = try await bedrock.converse(
                    with: model,
                    prompt: prompt,
                    history: conversation,
                    tools: tools,
                    toolResult: toolResult
                )
                print("\nAssistant: \(reply)")

                if let toolUse = try? reply.getToolUse() {
                    print("\nTool Use: \(toolUse.name)")
                    // print("Input: \(toolUse.input)")

                    let input = toolUse.input
                    let artist: String = input["artist"] ?? ""
                    let title: String = input["title"] ?? ""

                    // // Use default token generation from AppleMusicKit
                    let client = try await AppleMusicClient(storefront: "be")
                    let results: SearchResponse = try await client.searchByArtistAndTitle(
                        artist: artist, title: title)

                    let resultData = try JSONEncoder().encode(results)
                    let resultJSON = try JSONDecoder().decode(JSON.self, from: resultData)
                    toolResult = ToolResultBlock(resultJSON, id: toolUse.id)
                    prompt = nil

                    // let message = Message(toolResult)
                    // conversation.append(message)

                    // let reply = try await bedrock.converse(
                    //     with: model,
                    //     history: conversation,
                    //     tools: tools,
                    //     toolResult: toolResult
                    // )
                    // conversation = reply.history

                } else {
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
