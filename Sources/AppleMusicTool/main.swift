import AppleMusicKit
import MCPServerKit

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// create the server
let server = MCPServer(
    name: "AppleMusicTool",
    version: "1.0.0",
    tools: [
        searchByArtistTool,
        searchByTitleTool,
        searchByArtistAndTitleTool,
        getSongDetailsTool,
    ]
)
// start the server
try await server.startStdioServer()
