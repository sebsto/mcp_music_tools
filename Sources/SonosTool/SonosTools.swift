import MCP
import MCPServerKit
import SonosKit
import ToolMacro

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// Common input structure for room-specific commands
@SchemaDefinition
public struct RoomInput: Codable {
    /// The Sonos room/zone name (optional if default room is set)
    let room: String?
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
}

@Tool(
    name: "play",
    description: "Play music on a Sonos speaker",
    schema: RoomInput.self
)
public struct PlayTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.play(room: input.room)
        return "Playback started in room: \(input.room ?? "default room")"
    }
}

@Tool(
    name: "pause",
    description: "Pause music on a Sonos speaker",
    schema: RoomInput.self
)
public struct PauseTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.pause(room: input.room)
        return "Playback paused in room: \(input.room ?? "default room")"
    }
}

@Tool(
    name: "stop",
    description: "Stop music on a Sonos speaker",
    schema: RoomInput.self
)
public struct StopTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.stop(room: input.room)
        return "Playback stopped in room: \(input.room ?? "default room")"
    }
}

@Tool(
    name: "next",
    description: "Skip to next track on a Sonos speaker",
    schema: RoomInput.self
)
public struct NextTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.next(room: input.room)
        return "Skipped to next track in room: \(input.room ?? "default room")"
    }
}

@Tool(
    name: "previous",
    description: "Skip to previous track on a Sonos speaker",
    schema: RoomInput.self
)
public struct PreviousTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.previous(room: input.room)
        return "Skipped to previous track in room: \(input.room ?? "default room")"
    }
}

// Set Volume Tool
@SchemaDefinition
public struct SetVolumeInput: Codable {
    /// Volume level (0-100)
    let volume: Int
    /// The Sonos room/zone name (optional if default room is set)
    let room: String?
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
}

@Tool(
    name: "setVolume",
    description: "Set volume on a Sonos speaker",
    schema: SetVolumeInput.self
)
public struct SetVolumeTool: ToolProtocol {
    public typealias Input = SetVolumeInput
    public typealias Output = String

    public func handle(input: SetVolumeInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.setVolume(input.volume, room: input.room)
        return "Volume set to \(input.volume) in room: \(input.room ?? "default room")"
    }
}

@Tool(
    name: "clearQueue",
    description: "Clear the queue on a Sonos speaker",
    schema: RoomInput.self
)
public struct ClearQueueTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.clearQueue(room: input.room)
        return "Queue cleared in room: \(input.room ?? "default room")"
    }
}

// Get Queue Tool
@SchemaDefinition
public struct GetQueueInput: Codable {
    /// The Sonos room/zone name (optional if default room is set)
    let room: String?
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
    /// Limit the number of items returned
    let limit: Int?
    /// Offset for pagination (requires limit)
    let offset: Int?
    /// Include URIs in the response
    let detailed: Bool?
}

@Tool(
    name: "getQueue",
    description: "Get the current queue from a Sonos speaker",
    schema: GetQueueInput.self
)
public struct GetQueueTool: ToolProtocol {
    public typealias Input = GetQueueInput
    public typealias Output = String

    public func handle(input: GetQueueInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        let queue = try await client.getQueue(
            limit: input.limit,
            offset: input.offset,
            detailed: input.detailed ?? false,
            room: input.room
        )

        // Convert queue to JSON string
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(queue)
        return String(decoding: data, as: UTF8.self)
    }
}

// Play Apple Music Tool
@SchemaDefinition
public struct PlayAppleMusicInput: Codable {
    /// Type of Apple Music content (song, album, or playlist)
    let contentType: String
    /// Apple Music content ID
    let contentId: String
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
    name: "playAppleMusic",
    description: "Play Apple Music content on a Sonos speaker. This must be used to play apple music songs, titles or playslist now, next, or when asked to add items in the queue.",
    schema: PlayAppleMusicInput.self
)
public struct PlayAppleMusicTool: ToolProtocol {
    public typealias Input = PlayAppleMusicInput
    public typealias Output = String

    public func handle(input: PlayAppleMusicInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        let contentType: AppleMusicContentType
        switch input.contentType {
        case "song":
            contentType = .song
        case "album":
            contentType = .album
        case "playlist":
            contentType = .playlist
        default:
            throw MCPServerError.invalidParam(
                "contentType",
                "Must be one of: song, album, playlist"
            )
        }

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

        try await client.playAppleMusic(
            contentType: contentType,
            contentId: input.contentId,
            mode: mode,
            room: input.room
        )

        return
            "Playing Apple Music \(mode) \(input.contentType) with ID \(input.contentId) in room: \(input.room ?? "default room")"
    }
}

@Tool(
    name: "getState",
    description: "Get the current state of a Sonos speaker",
    schema: RoomInput.self
)
public struct GetStateTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        let state = try await client.getState(room: input.room)

        // Convert state to JSON string
        let encoder = JSONEncoder()
        let data = try encoder.encode(state)
        return String(decoding: data, as: UTF8.self)
    }
}

// Play Apple Music Playlist Tool
@SchemaDefinition
public struct PlayAppleMusicPlaylistInput: Codable {
    /// Apple Music playlist ID
    let playlistId: String
    /// Playback mode (now, next, or add to the queue)
    let mode: String?
    /// The Sonos room/zone name (optional if default room is set)
    let room: String?
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
}

@Tool(
    name: "playAppleMusicPlaylist",
    description: "Play an Apple Music playlist on a Sonos speaker",
    schema: PlayAppleMusicPlaylistInput.self
)
public struct PlayAppleMusicPlaylistTool: ToolProtocol {
    public typealias Input = PlayAppleMusicPlaylistInput
    public typealias Output = String

    public func handle(input: PlayAppleMusicPlaylistInput) async throws -> String {
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

        try await client.playAppleMusicPlaylist(
            playlistId: input.playlistId,
            mode: mode,
            room: input.room
        )

        return
            "Playing Apple Music playlist with ID \(input.playlistId) in room: \(input.room ?? "default room")"
    }
}

// Get Rooms Tool
@SchemaDefinition
public struct GetRoomsInput: Codable {
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
}

@Tool(
    name: "getRooms",
    description: "Get a list of available Sonos rooms/zones",
    schema: GetRoomsInput.self
)
public struct GetRoomsTool: ToolProtocol {
    public typealias Input = GetRoomsInput
    public typealias Output = String

    public func handle(input: GetRoomsInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005
        )

        let rooms = try await client.getRooms()

        // Convert rooms to JSON string
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(rooms)
        return String(decoding: data, as: UTF8.self)
    }
}

// Set Shuffle Tool
@SchemaDefinition
public struct SetShuffleInput: Codable {
    /// Whether to enable or disable shuffle mode
    let enabled: Bool
    /// The Sonos room/zone name (optional if default room is set)
    let room: String?
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
}

@Tool(
    name: "setShuffle",
    description: "Enable or disable shuffle mode on a Sonos speaker",
    schema: SetShuffleInput.self
)
public struct SetShuffleTool: ToolProtocol {
    public typealias Input = SetShuffleInput
    public typealias Output = String

    public func handle(input: SetShuffleInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.setShuffle(enabled: input.enabled, room: input.room)
        let status = input.enabled ? "enabled" : "disabled"
        return "Shuffle mode \(status) in room: \(input.room ?? "default room")"
    }
}

// Join Room Tool
@SchemaDefinition
public struct JoinRoomInput: Codable {
    /// The Sonos room/zone name that will join the group (optional if default room is set)
    let room: String?
    /// The room that is already in the target group
    let targetRoom: String
    /// Optional host address for the Sonos HTTP API (default: localhost)
    let host: String?
    /// Optional port for the Sonos HTTP API (default: 5005)
    let port: Int?
}

@Tool(
    name: "joinRoom",
    description: "Join a Sonos speaker to a group",
    schema: JoinRoomInput.self
)
public struct JoinRoomTool: ToolProtocol {
    public typealias Input = JoinRoomInput
    public typealias Output = String

    public func handle(input: JoinRoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.joinRoom(room: input.room, toGroup: input.targetRoom)
        return "Room \(input.room ?? "default room") joined group with \(input.targetRoom)"
    }
}

@Tool(
    name: "leaveGroup",
    description: "Remove a Sonos speaker from its group",
    schema: RoomInput.self
)
public struct LeaveGroupTool: ToolProtocol {
    public typealias Input = RoomInput
    public typealias Output = String

    public func handle(input: RoomInput) async throws -> String {
        let client = SonosClient(
            host: input.host ?? "localhost",
            port: input.port ?? 5005,
            defaultRoom: input.room
        )

        try await client.leaveGroup(room: input.room)
        return "Room \(input.room ?? "default room") left its group"
    }
}