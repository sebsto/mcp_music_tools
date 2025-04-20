import XCTest

@testable import SonosKit

final class SonosKitTests: XCTestCase {
  func testSonosClientInitialization() {
    let client = SonosClient(host: "localhost", port: 5005, defaultRoom: "Living Room")
    XCTAssertNotNil(client)
  }

  // Note: These tests require a running Sonos HTTP API server and actual Sonos speakers
  // They are commented out by default

  /*
  func testGetRooms() async throws {
      let client = SonosClient(host: "localhost", port: 5005)
      let rooms = try await client.getRooms()
      XCTAssertFalse(rooms.isEmpty)
  }
  
  func testPlayAndPause() async throws {
      let client = SonosClient(host: "localhost", port: 5005, defaultRoom: "Living Room")
      try await client.play()
      // Wait a moment to ensure the command is processed
      try await Task.sleep(nanoseconds: 2_000_000_000)
      try await client.pause()
  }
  
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
  */
}
