import MCP
import MCPServerKit

let server = MCPServer(
    name: "MusicPlayerTool",
    version: "1.0.0",
    tools: [
        MusicPlayerControlTool()
    ]
)

try await server.startStdioServer()

// let input = MusicPlayerControlInput(
//     action: "add",
//     song: "song",
//     artist: "artist",
//     album: "album",
//     song_id: 123,
//     artwork: "artwork",
//     timestamp: "today"
// )

// let controller = MusicPlayerControlTool()
// let result = try await controller.handler(input: input)
// print(result)
