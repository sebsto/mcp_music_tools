import Foundation

extension SonosClient {
    /// Play an Apple Music storefront chart playlist
    /// - Parameters:
    ///   - playlistId: The Apple Music playlist ID
    ///   - mode: Playback mode (now, next, queue)
    ///   - room: Optional room name (uses default room if nil)
    /// - Throws: `SonosError.noRoomSpecified` if no room is specified and no default room is set.
    ///           `SonosError.requestFailed` if the request fails.
    public func playStorefrontPlaylist(
        playlistId: String,
        mode: PlaybackMode = .now,
        room: String? = nil
    ) async throws {
        try await playAppleMusic(contentType: .playlist, contentId: playlistId, mode: mode, room: room)
    }
}
