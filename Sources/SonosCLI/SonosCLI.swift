import ArgumentParser
import Foundation
import SonosKit

@main
struct SonosCLI: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "sonos",
    abstract: "A command-line tool for controlling Sonos speakers",
    subcommands: [
      Play.self,
      Pause.self,
      Stop.self,
      Next.self,
      Previous.self,
      Volume.self,
      Queue.self,
      AppleMusic.self,
      StorefrontPlaylist.self,
      State.self,
      Rooms.self,
      Shuffle.self,
    ],
    defaultSubcommand: State.self
  )

  struct Options: ParsableArguments {
    @Option(name: .shortAndLong, help: "The host where the Sonos HTTP API is running")
    var host: String = "localhost"

    @Option(name: .shortAndLong, help: "The port where the Sonos HTTP API is running")
    var port: Int = 5005

    @Option(name: .shortAndLong, help: "The room/zone to control")
    var room: String?

    func createClient() -> SonosClient {
      return SonosClient(host: host, port: port, defaultRoom: room)
    }
  }

  struct Play: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Play music"
    )

    @OptionGroup var options: Options

    func run() async throws {
      let client = options.createClient()
      try await client.play(room: options.room)
      print("Playing music in room: \(options.room ?? "default")")
    }
  }

  struct Pause: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Pause music"
    )

    @OptionGroup var options: Options

    func run() async throws {
      let client = options.createClient()
      try await client.pause(room: options.room)
      print("Paused music in room: \(options.room ?? "default")")
    }
  }

  struct Stop: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Stop music"
    )

    @OptionGroup var options: Options

    func run() async throws {
      let client = options.createClient()
      try await client.stop(room: options.room)
      print("Stopped music in room: \(options.room ?? "default")")
    }
  }

  struct Next: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Skip to the next track"
    )

    @OptionGroup var options: Options

    func run() async throws {
      let client = options.createClient()
      try await client.next(room: options.room)
      print("Skipped to next track in room: \(options.room ?? "default")")
    }
  }

  struct Previous: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Skip to the previous track"
    )

    @OptionGroup var options: Options

    func run() async throws {
      let client = options.createClient()
      try await client.previous(room: options.room)
      print("Skipped to previous track in room: \(options.room ?? "default")")
    }
  }

  struct Volume: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Set the volume"
    )

    @OptionGroup var options: Options

    @Argument(help: "The volume level (0-100)")
    var level: Int

    func run() async throws {
      let client = options.createClient()
      try await client.setVolume(level, room: options.room)
      print("Set volume to \(level) in room: \(options.room ?? "default")")
    }
  }

  struct Queue: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Manage the queue",
      subcommands: [
        Add.self,
        Clear.self,
        List.self,
      ]
    )

    struct Add: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Add a track to the queue"
      )

      @OptionGroup var options: Options

      @Argument(help: "The URI of the track to add")
      var uri: String

      func run() async throws {
        let client = options.createClient()
        try await client.addToQueue(uri: uri, room: options.room)
        print("Added track to queue in room: \(options.room ?? "default")")
      }
    }

    struct Clear: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Clear the queue"
      )

      @OptionGroup var options: Options

      func run() async throws {
        let client = options.createClient()
        try await client.clearQueue(room: options.room)
        print("Cleared queue in room: \(options.room ?? "default")")
      }
    }

    struct List: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "List the current queue"
      )

      @OptionGroup var options: Options

      @Option(name: .shortAndLong, help: "Limit the number of items returned")
      var limit: Int?

      @Option(name: .shortAndLong, help: "Offset for pagination (requires limit)")
      var offset: Int?

      @Flag(name: .shortAndLong, help: "Include URIs in the response")
      var detailed: Bool = false

      func run() async throws {
        let client = options.createClient()
        let queue = try await client.getQueue(
          limit: limit, offset: offset, detailed: detailed, room: options.room)

        print("Queue for room: \(options.room ?? "default")")
        if queue.isEmpty {
          print("Queue is empty")
        } else {
          for (index, item) in queue.enumerated() {
            print("\(index + 1). \"\(item.title)\" by \(item.artist) from \(item.album)")
            if detailed, let uri = item.uri {
              print("   URI: \(uri)")
            }
          }
        }
      }
    }
  }

  struct AppleMusic: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Play Apple Music content",
      discussion: "Play, queue, or add Apple Music songs, albums, or playlists to the queue",
      subcommands: [
        Song.self,
        Album.self,
        Playlist.self,
      ]
    )

    struct Song: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Play or queue an Apple Music song"
      )

      @OptionGroup var options: Options

      @Argument(help: "The Apple Music song ID")
      var songId: String

      @Option(name: .shortAndLong, help: "Playback mode: now, next, or queue")
      var mode: String = "queue"

      func run() async throws {
        guard let playbackMode = PlaybackMode(rawValue: mode.lowercased()) else {
          throw ValidationError("Invalid playback mode. Use 'now', 'next', or 'queue'.")
        }

        let client = options.createClient()
        try await client.playAppleMusic(
          contentType: .song, contentId: songId, mode: playbackMode, room: options.room)
        print(
          "Apple Music song \(songId) \(playbackMode.rawValue == "now" ? "playing" : "added to \(playbackMode.rawValue)") in room: \(options.room ?? "default")"
        )
      }
    }

    struct Album: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Play or queue an Apple Music album"
      )

      @OptionGroup var options: Options

      @Argument(help: "The Apple Music album ID")
      var albumId: String

      @Option(name: .shortAndLong, help: "Playback mode: now, next, or queue")
      var mode: String = "queue"

      func run() async throws {
        guard let playbackMode = PlaybackMode(rawValue: mode.lowercased()) else {
          throw ValidationError("Invalid playback mode. Use 'now', 'next', or 'queue'.")
        }

        let client = options.createClient()
        try await client.playAppleMusic(
          contentType: .album, contentId: albumId, mode: playbackMode, room: options.room)
        print(
          "Apple Music album \(albumId) \(playbackMode.rawValue == "now" ? "playing" : "added to \(playbackMode.rawValue)") in room: \(options.room ?? "default")"
        )
      }
    }

    struct Playlist: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Play or queue an Apple Music playlist"
      )

      @OptionGroup var options: Options

      @Argument(help: "The Apple Music playlist ID")
      var playlistId: String

      @Option(name: .shortAndLong, help: "Playback mode: now, next, or queue")
      var mode: String = "queue"

      func run() async throws {
        guard let playbackMode = PlaybackMode(rawValue: mode.lowercased()) else {
          throw ValidationError("Invalid playback mode. Use 'now', 'next', or 'queue'.")
        }

        let client = options.createClient()
        try await client.playAppleMusicPlaylist(
          playlistId: playlistId, mode: playbackMode, room: options.room)
        print(
          "Apple Music playlist \(playlistId) \(playbackMode.rawValue == "now" ? "playing" : "added to \(playbackMode.rawValue)") in room: \(options.room ?? "default")"
        )
      }
    }
  }

  struct State: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Get the current state"
    )

    @OptionGroup var options: Options

    func run() async throws {
      let client = options.createClient()
      let state = try await client.getState(room: options.room)

      print("State for room: \(options.room ?? "default")")
      print("Playback state: \(state.playbackState)")
      print(
        "Current track: \(state.currentTrack.title ?? "Unknown") by \(state.currentTrack.artist ?? "Unknown")"
      )
      if let album = state.currentTrack.album {
        print("Album: \(album)")
      }
      print("Volume: \(state.volume)")
      print("Muted: \(state.mute)")
      print("Position: \(state.elapsedTimeFormatted)")

      if let nextTrack = state.nextTrack {
        print("\nNext track: \(nextTrack.title ?? "Unknown") by \(nextTrack.artist ?? "Unknown")")
      }
    }
  }

  struct Rooms: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "List all available rooms/zones"
    )

    @OptionGroup var options: Options

    func run() async throws {
      let client = options.createClient()
      let rooms = try await client.getRooms()

      print("Available rooms:")
      for (index, room) in rooms.enumerated() {
        print("\(index + 1). \(room)")
      }
    }
  }
  
  struct Shuffle: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Enable or disable shuffle mode"
    )

    @OptionGroup var options: Options
    
    @Argument(help: "Enable or disable shuffle mode (on/off)")
    var state: String
    
    func run() async throws {
      let client = options.createClient()
      
      switch state.lowercased() {
      case "on", "true", "1", "yes":
        try await client.setShuffle(enabled: true, room: options.room)
        print("Shuffle mode enabled in room: \(options.room ?? "default")")
      case "off", "false", "0", "no":
        try await client.setShuffle(enabled: false, room: options.room)
        print("Shuffle mode disabled in room: \(options.room ?? "default")")
      default:
        throw ValidationError("Invalid shuffle state. Use 'on' or 'off'.")
      }
    }
  }
}
