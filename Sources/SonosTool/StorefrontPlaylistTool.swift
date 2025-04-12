import Foundation
import MCPServerKit
import SonosKit

// Play Storefront Playlist Tool
struct PlayStorefrontPlaylistInput: Codable {
    let playlistId: String
    let mode: String?
    let room: String?
    let host: String?
    let port: Int?
}

let playStorefrontPlaylistToolSchema = """
    {
        "type": "object",
        "properties": {
            "playlistId": {
                "description": "Apple Music storefront playlist ID",
                "type": "string"
            },
            "mode": {
                "description": "Playback mode (now, next, or queue)",
                "type": "string",
                "enum": ["now", "next", "queue"]
            },
            "room": {
                "description": "The Sonos room/zone name (optional if default room is set)",
                "type": "string"
            },
            "host": {
                "description": "Optional host address for the Sonos HTTP API (default: localhost)",
                "type": "string"
            },
            "port": {
                "description": "Optional port for the Sonos HTTP API (default: 5005)",
                "type": "integer"
            }
        },
        "required": ["playlistId"]
    }
    """

let playStorefrontPlaylistTool = MCPTool<PlayStorefrontPlaylistInput, String>(
    name: "playStorefrontPlaylist",
    description: "Play an Apple Music storefront playlist on a Sonos speaker",
    inputSchema: playStorefrontPlaylistToolSchema,
    converter: { params in
        let playlistId = try MCPTool<String, String>.extractParameter(params, name: "playlistId")
        let mode = try? MCPTool<String, String>.extractParameter(params, name: "mode")
        let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
        let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
        let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

        return PlayStorefrontPlaylistInput(
            playlistId: playlistId,
            mode: mode,
            room: room,
            host: host,
            port: port
        )
    },
    body: { input async throws -> String in
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        let mode: PlaybackMode
        switch input.mode?.lowercased() {
        case "now", nil:
            mode = .now
        case "next":
            mode = .next
        case "queue":
            mode = .queue
        default:
            throw MCPServerError.invalidParam("mode", "Must be one of: now, next, queue")
        }

        try await client.playStorefrontPlaylist(
            playlistId: input.playlistId,
            mode: mode,
            room: input.room
        )

        return "Playing Apple Music storefront playlist with ID \(input.playlistId) in room: \(input.room ?? "default room")"
    }
)
