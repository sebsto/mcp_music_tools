import ArgumentParser
import Foundation
import SonosKit

struct StorefrontPlaylist: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "storefront-playlist",
    abstract: "Play an Apple Music storefront playlist"
  )

  @OptionGroup var options: SonosCLI.Options

  @Argument(help: "The Apple Music storefront playlist ID")
  var playlistId: String

  @Option(name: .shortAndLong, help: "Playback mode: now, next, or queue")
  var mode: String = "now"

  func run() async throws {
    guard let playbackMode = PlaybackMode(rawValue: mode.lowercased()) else {
      throw ValidationError("Invalid playback mode. Use 'now', 'next', or 'queue'.")
    }

    let client = options.createClient()
    try await client.playStorefrontPlaylist(
      playlistId: playlistId, mode: playbackMode, room: options.room)
    print(
      "Apple Music storefront playlist \(playlistId) \(playbackMode.rawValue == "now" ? "playing" : "added to \(playbackMode.rawValue)") in room: \(options.room ?? "default")"
    )
  }
}
