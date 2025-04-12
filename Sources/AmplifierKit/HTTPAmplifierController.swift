import Foundation

// Custom URLSession delegate to bypass SSL certificate validation
final class SSLBypassDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {
    func urlSession(
        _ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Accept any server certificate
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

public class HTTPAmplifierController: AmplifierController {
    private let config: AmplifierConfig
    private let session: URLSession
    private let sslBypassDelegate = SSLBypassDelegate()

    public init(config: AmplifierConfig) {
        self.config = config

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.tlsMinimumSupportedProtocolVersion = .TLSv12
        sessionConfig.tlsMaximumSupportedProtocolVersion = .TLSv13

        // Use the custom delegate to bypass SSL certificate validation
        self.session = URLSession(
            configuration: sessionConfig, delegate: sslBypassDelegate, delegateQueue: nil)
    }

    private func makeRequest(
        type: Int, path: String = "/ajax/globals/get_config", data: String? = nil
    ) async throws -> Data {
        var components = URLComponents()
        components.scheme = "https"
        components.host = config.host
        components.port = config.port

        if data != nil {
            components.path = "/ajax/globals/set_config"
            components.queryItems = [
                URLQueryItem(name: "type", value: String(type)),
                URLQueryItem(name: "data", value: data),
                URLQueryItem(name: "_", value: String(Int(Date().timeIntervalSince1970 * 1000))),
            ]
        } else {
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "type", value: String(type)),
                URLQueryItem(name: "_", value: String(Int(Date().timeIntervalSince1970 * 1000))),
            ]
        }

        guard let url = components.url else {
            throw AmplifierError.unexpectedError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, _) = try await session.data(for: request)
            return data
        } catch {
            throw AmplifierError.networkError(error)
        }
    }

    private func parseXMLData(_ data: Data) throws -> XMLDocument {
        do {
            let xmlDoc = try XMLDocument(data: data)
            return xmlDoc
        } catch {
            throw AmplifierError.invalidResponse
        }
    }

    public func powerOn() async throws {
        let data = "<MainZone><Power>1</Power></MainZone>"
        _ = try await makeRequest(type: 4, data: data)
    }

    public func powerOff() async throws {
        let data = "<MainZone><Power>3</Power></MainZone>"
        _ = try await makeRequest(type: 4, data: data)
    }

    public func switchToSource(index: Int) async throws {
        let data = "<Source zone=\"1\" index=\"\(index)\"></Source>"
        _ = try await makeRequest(type: 7, data: data)
    }

    public func switchToSonos() async throws {
        try await switchToSource(index: 4)
    }

    public func switchToAppleTV() async throws {
        try await switchToSource(index: 1)
    }

    public func getSourceNames() async throws -> [String] {
        let data = try await makeRequest(type: 7)
        let xmlDoc = try parseXMLData(data)

        guard let root = xmlDoc.rootElement() else {
            throw AmplifierError.invalidResponse
        }

        var sources: [String] = []
        // Based on the XML structure, we need to look for Name elements inside Source elements
        let nameNodes = try root.nodes(forXPath: "//Source/Name")

        for node in nameNodes {
            if let element = node as? XMLElement, let name = element.stringValue {
                sources.append(name)
            }
        }

        return sources
    }

    public func getMainZoneStatus() async throws -> (
        name: String, isPowered: Bool, sourceName: String?
    ) {
        // Request 1 from home path returns zone name and source name
        let sourceData = try await makeRequest(type: 1, path: "/ajax/home/get_config")
        let sourceXml = try parseXMLData(sourceData)

        // Request 4 returns power status
        let powerData = try await makeRequest(type: 4)
        let powerXml = try parseXMLData(powerData)

        // For debugging - print the XML responses
        // print("Source XML (home): \(String(data: sourceData, encoding: .utf8) ?? "Invalid data")")
        // print("Power XML: \(String(data: powerData, encoding: .utf8) ?? "Invalid data")")

        // Extract power status from request 4
        guard let powerRoot = powerXml.rootElement(),
            let powerNode = try powerRoot.nodes(forXPath: "//MainZone/Power").first as? XMLElement,
            let powerValue = powerNode.stringValue
        else {
            throw AmplifierError.invalidResponse
        }

        // Extract zone name and source name from request 1 (home path)
        guard let sourceRoot = sourceXml.rootElement() else {
            throw AmplifierError.invalidResponse
        }

        // Extract zone name
        guard
            let zoneNameNode = try sourceRoot.nodes(forXPath: "//MainZone/ZoneName").first
                as? XMLElement,
            let zoneName = zoneNameNode.stringValue
        else {
            throw AmplifierError.invalidResponse
        }

        // Extract source name (should be available in the same response)
        var sourceName: String? = nil
        if let sourceNameNode = try sourceRoot.nodes(forXPath: "//MainZone/SourceName").first
            as? XMLElement,
            let name = sourceNameNode.stringValue
        {
            sourceName = name
        }

        // Power value "1" means ON, "3" means OFF
        let isPowered = powerValue == "1"

        return (name: zoneName, isPowered: isPowered, sourceName: sourceName)
    }
}
