import Foundation

/// Enum representing the different types of Apple Music content.
public enum AppleMusicContentType: String {
  case song
  case album
  case playlist
}

/// Enum representing the different playback modes for music services.
public enum PlaybackMode: String {
  case now
  case next
  case queue
}

/// A client for interacting with the Sonos HTTP API.
public class SonosClient {
  /// The base URL for the Sonos HTTP API.
  private let baseURL: URL

  /// The default room/zone to control.
  private let defaultRoom: String?

  /// Creates a new Sonos client.
  /// - Parameters:
  ///   - host: The host where the Sonos HTTP API is running. Defaults to "localhost".
  ///   - port: The port where the Sonos HTTP API is running. Defaults to 5005.
  ///   - defaultRoom: The default room/zone to control. If nil, room must be specified for each request.
  public init(host: String = "localhost", port: Int = 5005, defaultRoom: String? = nil) {
    self.baseURL = URL(string: "http://\(host):\(port)")!
    self.defaultRoom = defaultRoom
  }

  /// Plays music in the specified room or the default room.
  /// - Parameter room: The room to play music in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func play(room: String? = nil) async throws {
    try await performAction("play", room: room)
  }

  /// Pauses music in the specified room or the default room.
  /// - Parameter room: The room to pause music in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func pause(room: String? = nil) async throws {
    try await performAction("pause", room: room)
  }

  /// Stops music in the specified room or the default room.
  /// - Parameter room: The room to stop music in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func stop(room: String? = nil) async throws {
    try await performAction("stop", room: room)
  }

  /// Skips to the next track in the specified room or the default room.
  /// - Parameter room: The room to skip to the next track in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func next(room: String? = nil) async throws {
    try await performAction("next", room: room)
  }

  /// Skips to the previous track in the specified room or the default room.
  /// - Parameter room: The room to skip to the previous track in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func previous(room: String? = nil) async throws {
    try await performAction("previous", room: room)
  }

  /// Adds a track to the queue in the specified room or the default room.
  /// - Parameters:
  ///   - uri: The URI of the track to add to the queue.
  ///   - room: The room to add the track to. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func addToQueue(uri: String, room: String? = nil) async throws {
    let roomName = try resolveRoom(room)
    let encodedURI = uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? uri
    let url = baseURL.appendingPathComponent(roomName)
      .appendingPathComponent("queue")
      .appendingPathComponent(encodedURI)

    try await performRequest(url: url)
  }

  /// Gets the current queue from the specified room or the default room.
  /// - Parameters:
  ///   - limit: Optional limit for the number of items to return.
  ///   - offset: Optional offset for pagination (requires limit to be set).
  ///   - detailed: Whether to include URIs in the response.
  ///   - room: The room to get the queue from. If nil, the default room is used.
  /// - Returns: An array of queue items.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func getQueue(
    limit: Int? = nil, offset: Int? = nil, detailed: Bool = false, room: String? = nil
  ) async throws -> [SonosQueueItem] {
    let roomName = try resolveRoom(room)
    var pathComponents = [roomName, "queue"]

    if let limit = limit {
      pathComponents.append("\(limit)")
      if let offset = offset {
        pathComponents.append("\(offset)")
      }
    }

    if detailed {
      pathComponents.append("detailed")
    }

    var url = baseURL
    for component in pathComponents {
      url = url.appendingPathComponent(component)
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    return try decoder.decode([SonosQueueItem].self, from: data)
  }

  /// Play an Apple Music playlist
  /// - Parameters:
  ///   - playlistId: The Apple Music playlist ID
  ///   - mode: Playback mode (now, next, queue)
  ///   - room: Optional room name (uses default room if nil)
  /// - Returns: Response from the Sonos API
  public func playAppleMusicPlaylist(
    playlistId: String, mode: PlaybackMode = .now, room: String? = nil
  ) async throws {
    try await playAppleMusic(contentType: .playlist, contentId: playlistId, mode: mode, room: room)
  }

  /// Plays, queues, or adds to queue an Apple Music track, album, or playlist in the specified room or the default room.
  /// - Parameters:
  ///   - contentType: The type of Apple Music content (song, album, or playlist).
  ///   - contentId: The ID of the Apple Music content.
  ///   - mode: The playback mode (now, next, or queue).
  ///   - room: The room to play the content in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func playAppleMusic(
    contentType: AppleMusicContentType, contentId: String, mode: PlaybackMode,
    room: String? = nil
  ) async throws {
    let roomName = try resolveRoom(room)
    let url = baseURL.appendingPathComponent(roomName)
      .appendingPathComponent("applemusic")
      .appendingPathComponent(mode.rawValue)
      .appendingPathComponent("\(contentType.rawValue):\(contentId)")

    try await performRequest(url: url)
  }

  /// Clears the queue in the specified room or the default room.
  /// - Parameter room: The room to clear the queue in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func clearQueue(room: String? = nil) async throws {
    try await performAction("clearqueue", room: room)
  }

  /// Gets the current state of the specified room or the default room.
  /// - Parameter room: The room to get the state of. If nil, the default room is used.
  /// - Returns: The current state of the room.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func getState(room: String? = nil) async throws -> SonosState {
    let roomName = try resolveRoom(room)
    let url = baseURL.appendingPathComponent(roomName)
      .appendingPathComponent("state")

    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    return try decoder.decode(SonosState.self, from: data)
  }

  /// Sets the volume in the specified room or the default room.
  /// - Parameters:
  ///   - volume: The volume to set (0-100).
  ///   - room: The room to set the volume in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func setVolume(_ volume: Int, room: String? = nil) async throws {
    try await performAction("volume/\(volume)", room: room)
  }

  /// Gets a list of all available rooms/zones.
  /// - Returns: An array of room names.
  /// - Throws: `SonosError.requestFailed` if the request fails.
  public func getRooms() async throws -> [String] {
    let url = baseURL.appendingPathComponent("zones")

    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let zones = try decoder.decode([SonosZone].self, from: data)

    return zones.flatMap { zone in
      zone.members.map { $0.roomName }
    }
  }

  /// Enables or disables shuffle mode in the specified room or the default room.
  /// - Parameters:
  ///   - enabled: Whether to enable or disable shuffle mode.
  ///   - room: The room to set shuffle mode in. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  public func setShuffle(enabled: Bool, room: String? = nil) async throws {
    let shuffleState = enabled ? "on" : "off"
    try await performAction("shuffle/\(shuffleState)", room: room)
  }

  // MARK: - Private Methods

  /// Performs an action on the specified room or the default room.
  /// - Parameters:
  ///   - action: The action to perform.
  ///   - room: The room to perform the action on. If nil, the default room is used.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  ///           `SonosError.requestFailed` if the request fails.
  private func performAction(_ action: String, room: String? = nil) async throws {
    let roomName = try resolveRoom(room)
    let url = baseURL.appendingPathComponent(roomName)
      .appendingPathComponent(action)

    try await performRequest(url: url)
  }

  /// Performs a request to the specified URL.
  /// - Parameter url: The URL to request.
  /// - Throws: `SonosError.requestFailed` if the request fails.
  private func performRequest(url: URL) async throws {
    let (_, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode)
    else {
      throw SonosError.requestFailed
    }
  }

  /// Resolves the room name to use for a request.
  /// - Parameter room: The room name to use. If nil, the default room is used.
  /// - Returns: The resolved room name.
  /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
  private func resolveRoom(_ room: String?) throws -> String {
    guard let roomName = room ?? defaultRoom else {
      throw SonosError.noRoomSpecified
    }
    return roomName
  }
}

/// Errors that can occur when interacting with the Sonos HTTP API.
public enum SonosError: Error {
  /// No room was specified and no default room is set.
  case noRoomSpecified
  /// The request to the Sonos HTTP API failed.
  case requestFailed
}
