import AppleMusicKit
import MCP
import MCPServerKit
import ToolMacro

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// Search by Artist Tool
@SchemaDefinition
public struct SearchByArtistInput: Codable {
    /// The artist name to search for
    let artist: String
    /// Optional Apple Music storefront (default: fr)
    let storefront: String?
}

@Tool(
    name: "searchByArtist",
    description: "Search the Apple Music catalog by artist name",
    schema: SearchByArtistInput.self
)
public struct SearchByArtistTool: MCPToolProtocol {
    public typealias Input = SearchByArtistInput
    public typealias Output = String

    public func handler(input: SearchByArtistInput) async throws -> String {
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let results = try await client.searchByArtist(input.artist)

        // Convert results to JSON string
        let encoder = JSONEncoder()
        let data = try encoder.encode(results)
        return String(decoding: data, as: UTF8.self)
    }
}

// Search by Title Tool
@SchemaDefinition
public struct SearchByTitleInput: Codable {
    /// The song title to search for
    let title: String
    /// Optional Apple Music storefront (default: fr)
    let storefront: String?
}

@Tool(
    name: "searchByTitle",
    description: "Search the Apple Music catalog by song title",
    schema: SearchByTitleInput.self
)
public struct SearchByTitleTool: MCPToolProtocol {
    public typealias Input = SearchByTitleInput
    public typealias Output = String

    public func handler(input: SearchByTitleInput) async throws -> String {
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let results = try await client.searchByTitle(input.title)

        // Convert results to JSON string
        let encoder = JSONEncoder()
        let data = try encoder.encode(results)
        return String(decoding: data, as: UTF8.self)
    }
}

// Search by Artist and Title Tool
@SchemaDefinition
public struct SearchByArtistAndTitleInput: Codable {
    /// The artist name to search for
    let artist: String
    /// The song title to search for
    let title: String
    /// Optional Apple Music storefront (default: fr)
    let storefront: String?
}

@Tool(
    name: "searchByArtistAndTitle",
    description: "Search the Apple Music catalog by both artist name and song title",
    schema: SearchByArtistAndTitleInput.self
)
public struct SearchByArtistAndTitleTool: MCPToolProtocol {
    public typealias Input = SearchByArtistAndTitleInput
    public typealias Output = String

    public func handler(input: SearchByArtistAndTitleInput) async throws -> String {
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let results = try await client.searchByArtistAndTitle(
            artist: input.artist,
            title: input.title
        )

        // Convert results to JSON string
        let encoder = JSONEncoder()
        let data = try encoder.encode(results)
        return String(decoding: data, as: UTF8.self)
    }
}

// Get Song Details Tool
@SchemaDefinition
public struct GetSongDetailsInput: Codable {
    /// The Apple Music song ID
    let id: String
    /// Optional Apple Music storefront (default: fr)
    let storefront: String?
}

@Tool(
    name: "getSongDetails",
    description: "Get detailed information about a specific song by ID",
    schema: GetSongDetailsInput.self
)
public struct GetSongDetailsTool: MCPToolProtocol {
    public typealias Input = GetSongDetailsInput
    public typealias Output = String

    public func handler(input: GetSongDetailsInput) async throws -> String {
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let songDetails = try await client.getSongDetails(id: input.id)

        // Convert results to JSON string
        let encoder = JSONEncoder()
        let data = try encoder.encode(songDetails)
        return String(decoding: data, as: UTF8.self)
    }
}