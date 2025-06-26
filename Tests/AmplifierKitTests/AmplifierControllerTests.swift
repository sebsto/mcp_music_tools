import Testing

@testable import AmplifierKit

@Suite("AmplifierController Tests")
struct AmplifierControllerTests {
    @Test("Power operations should work correctly")
    func testPowerOnOff() async throws {
        let controller = MockAmplifierController()

        // Test initial state
        let initialStatus = try await controller.getMainZoneStatus()
        #expect(!initialStatus.isPowered)

        // Test power on
        try await controller.powerOn()
        var status = try await controller.getMainZoneStatus()
        #expect(status.isPowered)
        #expect(controller.powerOnCallCount == 1)

        // Test power off
        try await controller.powerOff()
        status = try await controller.getMainZoneStatus()
        #expect(!status.isPowered)
        #expect(controller.powerOffCallCount == 1)
    }

    @Test("Source switching should work correctly")
    func testSourceSwitching() async throws {
        let controller = MockAmplifierController()

        // Test initial state
        #expect(controller.currentSource == "AppleTV")

        // Test switch to Sonos
        try await controller.switchToSonos()
        #expect(controller.currentSource == "Sonos")
        #expect(controller.switchToSonosCallCount == 1)

        // Test switch to Apple TV
        try await controller.switchToAppleTV()
        #expect(controller.currentSource == "AppleTV")
        #expect(controller.switchToAppleTVCallCount == 1)
    }

    @Test("Getting source names should work correctly")
    func testGetSourceNames() async throws {
        let controller = MockAmplifierController()

        let sources = try await controller.getSourceNames()
        #expect(sources == ["AppleTV", "Sonos", "CD", "Tuner"])
        #expect(controller.getSourceNamesCallCount == 1)
    }

    @Test("Getting main zone status should work correctly")
    func testGetMainZoneStatus() async throws {
        let controller = MockAmplifierController()

        // Test with default state
        var status = try await controller.getMainZoneStatus()
        #expect(status.name == "Main Zone")
        #expect(!status.isPowered)
        #expect(status.sourceName == "AppleTV")
        #expect(controller.getMainZoneStatusCallCount == 1)

        // Test after power on and source change
        try await controller.powerOn()
        try await controller.switchToSonos()

        status = try await controller.getMainZoneStatus()
        #expect(status.name == "Main Zone")
        #expect(status.isPowered)
        #expect(status.sourceName == "Sonos")
        #expect(controller.getMainZoneStatusCallCount == 2)
    }

    @Test("AmplifierConfig should initialize correctly")
    func testAmplifierConfig() throws {
        let config = AmplifierConfig(host: "192.168.1.37")
        #expect(config.host == "192.168.1.37")
        #expect(config.port == 10443)  // Default port

        let customConfig = AmplifierConfig(host: "192.168.1.38", port: 8443)
        #expect(customConfig.host == "192.168.1.38")
        #expect(customConfig.port == 8443)
    }
}
