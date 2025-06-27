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
        PlayTool(),
        PauseTool(),
        StopTool(),
        NextTool(),
        PreviousTool(),
        SetVolumeTool(),
        ClearQueueTool(),
        GetQueueTool(),
        PlayAppleMusicTool(),
        PlayAppleMusicPlaylistTool(),
        PlayStorefrontPlaylistTool(),
        GetStateTool(),
        GetRoomsTool(),
        SetShuffleTool(),
        JoinRoomTool(),
        LeaveGroupTool(),
    ]
)
// start the server
try await server.startStdioServer()