import MCP
import MCPServerKit
import ToolMacro

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@SchemaDefinition
public struct MusicPlayerControlInput: Codable {
    let action: String
    let song: String
    let artist: String
    let album: String
    let song_id: Int
    let artwork: String
    let timestamp: String
    public init(
        action: String,
        song: String,
        artist: String,
        album: String,
        song_id: Int,
        artwork: String,
        timestamp: String
    ) {
        self.action = action
        self.song = song
        self.artist = artist
        self.album = album
        self.song_id = song_id
        self.artwork = artwork
        self.timestamp = timestamp
    }
}

@Tool(
    name: "ControlMusicPlayer",
    description: "Control a simple music player by writing JSON commands to add or remove songs. This tool must be called one song at a time, either to add the song to the play queue or to remove it.",
    schema: MusicPlayerControlInput.self
)
public struct MusicPlayerControlTool: ToolProtocol {
    public typealias Input = MusicPlayerControlInput
    public typealias Output = String
    public init() {}

    public func handle(input: MusicPlayerControlInput) async throws -> String {
        let webMusicPlayerPath = "/Users/stormacq/Documents/amazon/code/swift/bedrock/music_player_web"
        let filePath = "\(webMusicPlayerPath)/music_queue_control.json"
        let fileURL = URL(fileURLWithPath: filePath)
        
        var commands: [MusicPlayerControlInput] = []
        
        if FileManager.default.fileExists(atPath: filePath) {
            let existingData = try Data(contentsOf: fileURL)
            commands = try JSONDecoder().decode([MusicPlayerControlInput].self, from: existingData)
        }
        
        commands.append(input)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(commands)
        try jsonData.write(to: fileURL)
        
        return "Command added to \(filePath) (\(commands.count) total commands)"
    }
}