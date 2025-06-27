import Foundation
import MCPServerKit
import OpenURLKit
import ToolMacro

// Open URL Tool input data structure
@SchemaDefinition
struct OpenURLInput: Decodable {
    /// The URL to open in the default browser
    let url: String
}

@Tool(
    name: "Open URL",
    description: "Opens a URL in the default browser",
    schema: OpenURLInput.self
)
struct OpenURLTool: MCPToolProtocol {
    typealias Input = OpenURLInput
    typealias Output = String
    func handler(input: OpenURLInput) async throws -> String {
        do {
            try URLOpener.open(input.url)
            return "Successfully opened URL: \(input.url)"
        } catch URLOpenerError.invalidURL {
            throw MCPServerError.invalidParam("url", "The provided URL is invalid")
        } catch {
            throw MCPServerError.invalidParam("url", "Failed to open URL: \(error.localizedDescription)")
        }
    }
}
