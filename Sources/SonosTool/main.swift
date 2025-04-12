import MCPServerKit
import SonosKit

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

// create the server
let server = MCPServer(
  name: "SonosTool",
  version: "1.0.0",
  tools: [
    playTool,
    pauseTool,
    stopTool,
    nextTool,
    previousTool,
    setVolumeTool,
    addToQueueTool,
    clearQueueTool,
    getQueueTool,
    playAppleMusicTool,
    playAppleMusicPlaylistTool,
    playStorefrontPlaylistTool,
    getStateTool,
    getRoomsTool,
  ]
)
// start the server
try await server.startStdioServer()
