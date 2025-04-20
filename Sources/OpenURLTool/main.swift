import MCPServerKit
import OpenURLKit

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

// create the server
let server = MCPServer(
  name: "OpenURLTool",
  version: "1.0.0",
  tools: [
    openURLTool
  ]
)

// start the server
try await server.startStdioServer()
