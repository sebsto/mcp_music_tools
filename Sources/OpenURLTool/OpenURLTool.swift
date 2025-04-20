import Foundation
import MCPServerKit
import OpenURLKit

// Open URL Tool
struct OpenURLInput: Codable {
    let url: String
}

let openURLToolSchema = """
{
    "type": "object",
    "properties": {
        "url": {
            "description": "The URL to open in the default browser",
            "type": "string"
        }
    },
    "required": ["url"]
}
"""

let openURLTool = MCPTool<OpenURLInput, String>(
    name: "openURL",
    description: "Opens a URL in the default browser",
    inputSchema: openURLToolSchema,
    converter: { params in
        let url = try MCPTool<String, String>.extractParameter(params, name: "url")
        return OpenURLInput(url: url)
    },
    body: { input async throws -> String in
        do {
            try URLOpener.open(input.url)
            return "Successfully opened URL: \(input.url)"
        } catch URLOpenerError.invalidURL {
            throw MCPServerError.invalidParam("url", "The provided URL is invalid")
        } catch {
            throw MCPServerError.invalidParam("url", "Failed to open URL: \(error.localizedDescription)")
        }
    }
)
