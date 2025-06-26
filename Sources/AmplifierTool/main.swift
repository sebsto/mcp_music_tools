import AmplifierKit
import MCPServerKit

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// create the server
let server = MCPServer(
    name: "AmplifierTool",
    version: "1.0.0",
    tools: [
        powerOnTool,
        powerOffTool,
        switchToSonosTool,
        switchToAppleTVTool,
        switchToSourceTool,
        getSourcesTool,
        getStatusTool,
    ]
)
// start the server
try await server.startStdioServer()
