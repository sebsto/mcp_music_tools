import MCP
import MCPServerKit
import SonosKit

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

// Common input structure for room-specific commands
struct RoomInput: Codable {
  let room: String?
  let host: String?
  let port: Int?
}

// Play Tool
let playToolSchema = """
  {
      "type": "object",
      "properties": {
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
      }
  }
  """

let playTool = MCPTool<RoomInput, String>(
  name: "play",
  description: "Play music on a Sonos speaker",
  inputSchema: playToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    try await client.play(room: input.room)
    return "Playback started in room: \(input.room ?? "default room")"
  }
)

// Pause Tool
let pauseToolSchema = """
  {
      "type": "object",
      "properties": {
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
      }
  }
  """

let pauseTool = MCPTool<RoomInput, String>(
  name: "pause",
  description: "Pause music on a Sonos speaker",
  inputSchema: pauseToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    try await client.pause(room: input.room)
    return "Playback paused in room: \(input.room ?? "default room")"
  }
)

// Stop Tool
let stopToolSchema = """
  {
      "type": "object",
      "properties": {
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
      }
  }
  """

let stopTool = MCPTool<RoomInput, String>(
  name: "stop",
  description: "Stop music on a Sonos speaker",
  inputSchema: stopToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    try await client.stop(room: input.room)
    return "Playback stopped in room: \(input.room ?? "default room")"
  }
)

// Next Tool
let nextToolSchema = """
  {
      "type": "object",
      "properties": {
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
      }
  }
  """

let nextTool = MCPTool<RoomInput, String>(
  name: "next",
  description: "Skip to next track on a Sonos speaker",
  inputSchema: nextToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    try await client.next(room: input.room)
    return "Skipped to next track in room: \(input.room ?? "default room")"
  }
)

// Previous Tool
let previousToolSchema = """
  {
      "type": "object",
      "properties": {
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
      }
  }
  """

let previousTool = MCPTool<RoomInput, String>(
  name: "previous",
  description: "Skip to previous track on a Sonos speaker",
  inputSchema: previousToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    try await client.previous(room: input.room)
    return "Skipped to previous track in room: \(input.room ?? "default room")"
  }
)

// Set Volume Tool
struct SetVolumeInput: Codable {
  let volume: Int
  let room: String?
  let host: String?
  let port: Int?
}

let setVolumeToolSchema = """
  {
      "type": "object",
      "properties": {
          "volume": {
              "description": "Volume level (0-100)",
              "type": "integer",
              "minimum": 0,
              "maximum": 100
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
      "required": ["volume"]
  }
  """

let setVolumeTool = MCPTool<SetVolumeInput, String>(
  name: "setVolume",
  description: "Set volume on a Sonos speaker",
  inputSchema: setVolumeToolSchema,
  converter: { params in
    let volume = try MCPTool<Int, Int>.extractParameter(params, name: "volume")
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return SetVolumeInput(
      volume: volume,
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

    try await client.setVolume(input.volume, room: input.room)
    return "Volume set to \(input.volume) in room: \(input.room ?? "default room")"
  }
)

// Add To Queue Tool
// struct AddToQueueInput: Codable {
//   let uri: String
//   let room: String?
//   let host: String?
//   let port: Int?
// }

// let addToQueueToolSchema = """
//   {
//       "type": "object",
//       "properties": {
//           "uri": {
//               "description": "URI of the track to add to the queue",
//               "type": "string"
//           },
//           "room": {
//               "description": "The Sonos room/zone name (optional if default room is set)",
//               "type": "string"
//           },
//           "host": {
//               "description": "Optional host address for the Sonos HTTP API (default: localhost)",
//               "type": "string"
//           },
//           "port": {
//               "description": "Optional port for the Sonos HTTP API (default: 5005)",
//               "type": "integer"
//           }
//       },
//       "required": ["uri"]
//   }
//   """

// let addToQueueTool = MCPTool<AddToQueueInput, String>(
//   name: "addToQueue",
//   description: "Add a track to the queue on a Sonos speaker",
//   inputSchema: addToQueueToolSchema,
//   converter: { params in
//     let uri = try MCPTool<String, String>.extractParameter(params, name: "uri")
//     let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
//     let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
//     let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

//     return AddToQueueInput(
//       uri: uri,
//       room: room,
//       host: host,
//       port: port
//     )
//   },
//   body: { input async throws -> String in
//     let client = SonosClient(
//       host: input.host ?? "localhost",
//       port: input.port ?? 5005,
//       defaultRoom: input.room
//     )

//     try await client.addToQueue(uri: input.uri, room: input.room)
//     return "Added track to queue in room: \(input.room ?? "default room")"
//   }
// )

// Clear Queue Tool
let clearQueueToolSchema = """
  {
      "type": "object",
      "properties": {
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
      }
  }
  """

let clearQueueTool = MCPTool<RoomInput, String>(
  name: "clearQueue",
  description: "Clear the queue on a Sonos speaker",
  inputSchema: clearQueueToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    try await client.clearQueue(room: input.room)
    return "Queue cleared in room: \(input.room ?? "default room")"
  }
)

// Get Queue Tool
struct GetQueueInput: Codable {
  let room: String?
  let host: String?
  let port: Int?
  let limit: Int?
  let offset: Int?
  let detailed: Bool?
}

let getQueueToolSchema = """
  {
      "type": "object",
      "properties": {
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
          },
          "limit": {
              "description": "Limit the number of items returned",
              "type": "integer"
          },
          "offset": {
              "description": "Offset for pagination (requires limit)",
              "type": "integer"
          },
          "detailed": {
              "description": "Include URIs in the response",
              "type": "boolean"
          }
      }
  }
  """

let getQueueTool = MCPTool<GetQueueInput, String>(
  name: "getQueue",
  description: "Get the current queue from a Sonos speaker",
  inputSchema: getQueueToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")
    let limit = try? MCPTool<Int, Int>.extractParameter(params, name: "limit")
    let offset = try? MCPTool<Int, Int>.extractParameter(params, name: "offset")
    let detailed = try? MCPTool<Bool, Bool>.extractParameter(params, name: "detailed")

    return GetQueueInput(
      room: room,
      host: host,
      port: port,
      limit: limit,
      offset: offset,
      detailed: detailed
    )
  },
  body: { input async throws -> String in
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
)

// Play Apple Music Tool
struct PlayAppleMusicInput: Codable {
  let contentType: String
  let contentId: String
  let mode: String?
  let room: String?
  let host: String?
  let port: Int?
}

let playAppleMusicToolSchema = """
  {
      "type": "object",
      "properties": {
          "contentType": {
              "description": "Type of Apple Music content (song, album, or playlist)",
              "type": "string",
              "enum": ["song", "album", "playlist"]
          },
          "contentId": {
              "description": "Apple Music content ID",
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
      "required": ["contentType", "contentId"]
  }
  """

let playAppleMusicTool = MCPTool<PlayAppleMusicInput, String>(
  name: "playAppleMusic",
  description:
    "Play Apple Music content on a Sonos speaker. This must be used to play apple music songs, titles or playslist now, next, or when asked to add items in the queue.",
  inputSchema: playAppleMusicToolSchema,
  converter: { params in
    let contentType = try MCPTool<String, String>.extractParameter(params, name: "contentType")
    let contentId = try MCPTool<String, String>.extractParameter(params, name: "contentId")
    let mode = try? MCPTool<String, String>.extractParameter(params, name: "mode")
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return PlayAppleMusicInput(
      contentType: contentType,
      contentId: contentId,
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
        "contentType", "Must be one of: song, album, playlist")
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
)

// Get State Tool
let getStateToolSchema = """
  {
      "type": "object",
      "properties": {
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
      }
  }
  """

let getStateTool = MCPTool<RoomInput, String>(
  name: "getState",
  description: "Get the current state of a Sonos speaker",
  inputSchema: getStateToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    let state = try await client.getState(room: input.room)

    // Convert state to JSON string
    let encoder = JSONEncoder()
    // encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(state)
    return String(decoding: data, as: UTF8.self)
  }
)

// Play Apple Music Playlist Tool
struct PlayAppleMusicPlaylistInput: Codable {
  let playlistId: String
  let mode: String?
  let room: String?
  let host: String?
  let port: Int?
}

let playAppleMusicPlaylistToolSchema = """
  {
      "type": "object",
      "properties": {
          "playlistId": {
              "description": "Apple Music playlist ID",
              "type": "string"
          },
          "mode": {
              "description": "Playback mode (now, next, or add to the queue)",
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

let playAppleMusicPlaylistTool = MCPTool<PlayAppleMusicPlaylistInput, String>(
  name: "playAppleMusicPlaylist",
  description: "Play an Apple Music playlist on a Sonos speaker",
  inputSchema: playAppleMusicPlaylistToolSchema,
  converter: { params in
    let playlistId = try MCPTool<String, String>.extractParameter(params, name: "playlistId")
    let mode = try? MCPTool<String, String>.extractParameter(params, name: "mode")
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return PlayAppleMusicPlaylistInput(
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

    try await client.playAppleMusicPlaylist(
      playlistId: input.playlistId,
      mode: mode,
      room: input.room
    )

    return
      "Playing Apple Music playlist with ID \(input.playlistId) in room: \(input.room ?? "default room")"
  }
)

// Get Rooms Tool
struct GetRoomsInput: Codable {
  let host: String?
  let port: Int?
}

let getRoomsToolSchema = """
  {
      "type": "object",
      "properties": {
          "host": {
              "description": "Optional host address for the Sonos HTTP API (default: localhost)",
              "type": "string"
          },
          "port": {
              "description": "Optional port for the Sonos HTTP API (default: 5005)",
              "type": "integer"
          }
      }
  }
  """

let getRoomsTool = MCPTool<GetRoomsInput, String>(
  name: "getRooms",
  description: "Get a list of available Sonos rooms/zones",
  inputSchema: getRoomsToolSchema,
  converter: { params in
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return GetRoomsInput(
      host: host,
      port: port
    )
  },
  body: { input async throws -> String in
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
)

// Set Shuffle Tool
struct SetShuffleInput: Codable {
  let enabled: Bool
  let room: String?
  let host: String?
  let port: Int?
}

let setShuffleToolSchema = """
  {
      "type": "object",
      "properties": {
          "enabled": {
              "description": "Whether to enable or disable shuffle mode",
              "type": "boolean"
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
      "required": ["enabled"]
  }
  """

let setShuffleTool = MCPTool<SetShuffleInput, String>(
  name: "setShuffle",
  description: "Enable or disable shuffle mode on a Sonos speaker",
  inputSchema: setShuffleToolSchema,
  converter: { params in
    let enabled = try MCPTool<Bool, Bool>.extractParameter(params, name: "enabled")
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return SetShuffleInput(
      enabled: enabled,
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

    try await client.setShuffle(enabled: input.enabled, room: input.room)
    let status = input.enabled ? "enabled" : "disabled"
    return "Shuffle mode \(status) in room: \(input.room ?? "default room")"
  }
)

// Join Room Tool
struct JoinRoomInput: Codable {
  let room: String?
  let targetRoom: String
  let host: String?
  let port: Int?
}

let joinRoomToolSchema = """
  {
      "type": "object",
      "properties": {
          "room": {
              "description": "The Sonos room/zone name that will join the group (optional if default room is set)",
              "type": "string"
          },
          "targetRoom": {
              "description": "The room that is already in the target group",
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
      "required": ["targetRoom"]
  }
  """

let joinRoomTool = MCPTool<JoinRoomInput, String>(
  name: "joinRoom",
  description: "Join a Sonos speaker to a group",
  inputSchema: joinRoomToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let targetRoom = try MCPTool<String, String>.extractParameter(params, name: "targetRoom")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return JoinRoomInput(
      room: room,
      targetRoom: targetRoom,
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

    try await client.joinRoom(room: input.room, toGroup: input.targetRoom)
    return "Room \(input.room ?? "default room") joined group with \(input.targetRoom)"
  }
)

// Leave Group Tool
let leaveGroupToolSchema = """
  {
      "type": "object",
      "properties": {
          "room": {
              "description": "The Sonos room/zone name to remove from its group (optional if default room is set)",
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
      }
  }
  """

let leaveGroupTool = MCPTool<RoomInput, String>(
  name: "leaveGroup",
  description: "Remove a Sonos speaker from its group",
  inputSchema: leaveGroupToolSchema,
  converter: { params in
    let room = try? MCPTool<String, String>.extractParameter(params, name: "room")
    let host = try? MCPTool<String, String>.extractParameter(params, name: "host")
    let port = try? MCPTool<Int, Int>.extractParameter(params, name: "port")

    return RoomInput(
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

    try await client.leaveGroup(room: input.room)
    return "Room \(input.room ?? "default room") left its group"
  }
)
