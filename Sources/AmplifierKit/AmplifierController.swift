import Foundation

public protocol AmplifierController {
    func powerOn() async throws
    func powerOff() async throws
    func switchToSonos() async throws
    func switchToAppleTV() async throws
    func switchToSource(index: Int) async throws
    func getSourceNames() async throws -> [String]
    func getMainZoneStatus() async throws -> (name: String, isPowered: Bool)
}

public enum AmplifierError: Error {
    case networkError(Error)
    case invalidResponse
    case unexpectedError(String)
}

public struct AmplifierConfig {
    public let host: String
    public let port: Int

    public init(host: String, port: Int = 10443) {
        self.host = host
        self.port = port
    }
}
