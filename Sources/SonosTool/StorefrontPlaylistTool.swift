import Foundation
import MCPServerKit
import SonosKit
import ToolMacro

// Play Storefront Playlist Tool
@SchemaDefinition
public struct PlayStorefrontPlaylistInput: Codable {
    /// Apple Music storefront playlist ID
    let playlistId: String
    /// Playback mode (now, next, or queue)
    let mode: String?
    /// The Sonos room/zone name (optional if default room is set)
    let room: String?
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
}

@Tool(
    name: "playStorefrontPlaylist",
    description: "Play an Apple Music storefront playlist on a Sonos speaker",
    schema: PlayStorefrontPlaylistInput.self
)
public struct PlayStorefrontPlaylistTool: ToolProtocol {
    public typealias Input = PlayStorefrontPlaylistInput
    public typealias Output = String

    public func handle(input: PlayStorefrontPlaylistInput) async throws -> String {
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

        return
            "Playing Apple Music storefront playlist with ID \(input.playlistId) in room: \(input.room ?? "default room")"
    }
}