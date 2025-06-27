import Testing

@testable import SonosKit

let sonosAPIServerStarted = false  // Set to false to use mock data

@Suite("SonosKit Tests", .disabled(if: !sonosAPIServerStarted, "Requires a running Sonos HTTP API server"))
struct SonosKitTests {

    // Note: These tests require a running Sonos HTTP API server and actual Sonos speakers
    // They are commented out by default

    @Test("Get rooms should return available rooms")
    func testGetRooms() async throws {
        let client = SonosClient(host: "localhost", port: 5005)
        let rooms = try await client.getRooms()
        #expect(!rooms.isEmpty, "Should return at least one room")
    }

    @Test("Play and pause should work correctly")
    func testPlayAndPause() async throws {
        let client = SonosClient(host: "localhost", port: 5005, defaultRoom: "Living Room")
        try await client.play()
        // Wait a moment to ensure the command is processed
        try await Task.sleep(nanoseconds: 2_000_000_000)
        try await client.pause()
    }

    @Test("Volume control should work correctly")
    func testVolumeControl() async throws {
        let client = SonosClient(host: "localhost", port: 5005, defaultRoom: "Living Room")
        let state = try await client.getState()
        let originalVolume = state.volume

        // Set to a new volume
        try await client.setVolume(10)

        // Wait a moment to ensure the command is processed
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Restore original volume
        try await client.setVolume(originalVolume)
    }
}
