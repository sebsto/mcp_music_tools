import Foundation

/// Represents the state of a Sonos player.
public struct SonosState: Codable {
  /// The current playback state.
  public let playbackState: String
  /// The current track information.
  public let currentTrack: SonosTrack
  /// The next track information, if available.
  public let nextTrack: SonosTrack?
  /// The current volume level (0-100).
  public let volume: Int
  /// Whether the player is muted.
  public let mute: Bool
  /// The current playback position in seconds.
  public let elapsedTime: Int
  /// The duration of the current track in seconds.
  public let elapsedTimeFormatted: String
  /// The current queue.
  public let queue: [SonosTrack]?

  /// The coding keys for the Sonos state.
  enum CodingKeys: String, CodingKey {
    case playbackState = "playbackState"
    case currentTrack = "currentTrack"
    case nextTrack = "nextTrack"
    case volume = "volume"
    case mute = "mute"
    case elapsedTime = "elapsedTime"
    case elapsedTimeFormatted = "elapsedTimeFormatted"
    case queue = "queue"
  }
}

/// Represents a queue item in the Sonos system.
public struct SonosQueueItem: Codable {
  /// The title of the track.
  public let title: String
  /// The artist of the track.
  public let artist: String
  /// The album of the track.
  public let album: String
  /// The album art URL.
  public let albumArtURI: String?
  /// The URI of the track (only available in detailed mode).
  public let uri: String?

  /// The coding keys for the Sonos queue item.
  enum CodingKeys: String, CodingKey {
    case title
    case artist
    case album
    case albumArtURI
    case uri
  }
}

/// Represents a track in the Sonos system.
public struct SonosTrack: Codable {
  /// The title of the track.
  public let title: String?
  /// The artist of the track.
  public let artist: String?
  /// The album of the track.
  public let album: String?
  /// The album art URL.
  public let albumArtURI: String?
  /// The duration of the track in seconds.
  public let duration: Int
  /// The URI of the track.
  public let uri: String?

  /// The coding keys for the Sonos track.
  enum CodingKeys: String, CodingKey {
    case title = "title"
    case artist = "artist"
    case album = "album"
    case albumArtURI = "albumArtURI"
    case duration = "duration"
    case uri = "uri"
  }
}

/// Represents a Sonos zone.
public struct SonosZone: Codable {
  /// The coordinator of the zone.
  public let coordinator: SonosMember
  /// The members of the zone.
  public let members: [SonosMember]
  /// The UUID of the zone.
  public let uuid: String

  /// The coding keys for the Sonos zone.
  enum CodingKeys: String, CodingKey {
    case coordinator = "coordinator"
    case members = "members"
    case uuid = "uuid"
  }
}

/// Represents a member of a Sonos zone.
public struct SonosMember: Codable {
  /// The UUID of the member.
  public let uuid: String
  /// The room name of the member.
  public let roomName: String
  /// The state of the member.
  public let state: SonosMemberState

  /// The coding keys for the Sonos member.
  enum CodingKeys: String, CodingKey {
    case uuid = "uuid"
    case roomName = "roomName"
    case state = "state"
  }
}

/// Represents the state of a Sonos member.
public struct SonosMemberState: Codable {
  /// The current volume level (0-100).
  public let volume: Int
  /// Whether the member is muted.
  public let mute: Bool
  /// The current playback state (e.g., "PLAYING", "STOPPED", "PAUSED_PLAYBACK").
  public let playbackState: String?
  /// The equalizer settings.
  public let equalizer: SonosEqualizer?
  /// The current track information.
  public let currentTrack: SonosTrack?

  /// The coding keys for the Sonos member state.
  enum CodingKeys: String, CodingKey {
    case volume = "volume"
    case mute = "mute"
    case playbackState = "playbackState"
    case equalizer = "equalizer"
    case currentTrack = "currentTrack"
  }

  /// Computed property to determine if the member is playing.
  public var isPlaying: Bool {
    return playbackState == "PLAYING"
  }
}

/// Represents the equalizer settings for a Sonos speaker.
public struct SonosEqualizer: Codable {
  /// The bass level.
  public let bass: Int
  /// The treble level.
  public let treble: Int
  /// Whether loudness is enabled.
  public let loudness: Bool

  /// The coding keys for the Sonos equalizer.
  enum CodingKeys: String, CodingKey {
    case bass = "bass"
    case treble = "treble"
    case loudness = "loudness"
  }
}
