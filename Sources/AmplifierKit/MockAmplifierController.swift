import Foundation

public class MockAmplifierController: AmplifierController {
    public var isPowered: Bool = false
    public var currentSource: String = "AppleTV"
    public var zoneName: String = "Main Zone"
    public var availableSources = ["AppleTV", "Sonos", "CD", "Tuner"]

    public var powerOnCallCount = 0
    public var powerOffCallCount = 0
    public var switchToSonosCallCount = 0
    public var switchToAppleTVCallCount = 0
    public var switchToSourceCallCount = 0
    public var lastSourceIndex = 0
    public var getSourceNamesCallCount = 0
    public var getMainZoneStatusCallCount = 0

    public init() {}

    public func powerOn() async throws {
        powerOnCallCount += 1
        isPowered = true
    }

    public func powerOff() async throws {
        powerOffCallCount += 1
        isPowered = false
    }

    public func switchToSource(index: Int) async throws {
        switchToSourceCallCount += 1
        lastSourceIndex = index

        // Update current source if index is valid
        if index > 0 && index <= availableSources.count {
            currentSource = availableSources[index - 1]
        }
    }

    public func switchToSonos() async throws {
        switchToSonosCallCount += 1
        try await switchToSource(index: availableSources.firstIndex(of: "Sonos")! + 1)
    }

    public func switchToAppleTV() async throws {
        switchToAppleTVCallCount += 1
        try await switchToSource(index: availableSources.firstIndex(of: "AppleTV")! + 1)
    }

    public func getSourceNames() async throws -> [String] {
        getSourceNamesCallCount += 1
        return availableSources
    }

    public func getMainZoneStatus() async throws -> (
        name: String, isPowered: Bool, sourceName: String?
    ) {
        getMainZoneStatusCallCount += 1
        return (name: zoneName, isPowered: isPowered, sourceName: currentSource)
    }

    public func reset() {
        isPowered = false
        currentSource = "AppleTV"
        powerOnCallCount = 0
        powerOffCallCount = 0
        switchToSonosCallCount = 0
        switchToAppleTVCallCount = 0
        switchToSourceCallCount = 0
        lastSourceIndex = 0
        getSourceNamesCallCount = 0
        getMainZoneStatusCallCount = 0
    }
}
