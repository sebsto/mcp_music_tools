import AppleMusicKit
import MCP
import MCPServerKit

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// Search by Artist Tool
struct SearchByArtistInput: Codable {
    let artist: String
    let storefront: String?
}

let searchByArtistToolSchema = """
    {
        "type": "object",
        "properties": {
            "artist": {
                "description": "The artist name to search for",
                "type": "string"
            },
            "storefront": {
                "description": "Optional Apple Music storefront (default: fr)",
                "type": "string"
            }
        },
        "required": ["artist"]
    }
    """

let searchByArtistTool = MCPTool<SearchByArtistInput, String>(
    name: "searchByArtist",
    description: "Search the Apple Music catalog by artist name",
    inputSchema: searchByArtistToolSchema,
    converter: { params in
        let artist = try MCPTool<String, String>.extractParameter(params, name: "artist")
        let storefront = try? MCPTool<String, String>.extractParameter(params, name: "storefront")

        return SearchByArtistInput(
            artist: artist,
            storefront: storefront
        )
    },
    body: { input async throws -> String in
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let results = try await client.searchByArtist(input.artist)

        // Convert results to JSON string
        let encoder = JSONEncoder()
        // encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(results)
        return String(decoding: data, as: UTF8.self)
    }
)

// Search by Title Tool
struct SearchByTitleInput: Codable {
    let title: String
    let storefront: String?
}

let searchByTitleToolSchema = """
    {
        "type": "object",
        "properties": {
            "title": {
                "description": "The song title to search for",
                "type": "string"
            },
            "storefront": {
                "description": "Optional Apple Music storefront (default: fr)",
                "type": "string"
            }
        },
        "required": ["title"]
    }
    """

let searchByTitleTool = MCPTool<SearchByTitleInput, String>(
    name: "searchByTitle",
    description: "Search the Apple Music catalog by song title",
    inputSchema: searchByTitleToolSchema,
    converter: { params in
        let title = try MCPTool<String, String>.extractParameter(params, name: "title")
        let storefront = try? MCPTool<String, String>.extractParameter(params, name: "storefront")

        return SearchByTitleInput(
            title: title,
            storefront: storefront
        )
    },
    body: { input async throws -> String in
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let results = try await client.searchByTitle(input.title)

        // Convert results to JSON string
        let encoder = JSONEncoder()
        // encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(results)
        return String(decoding: data, as: UTF8.self)
    }
)

// Search by Artist and Title Tool
struct SearchByArtistAndTitleInput: Codable {
    let artist: String
    let title: String
    let storefront: String?
}

let searchByArtistAndTitleToolSchema = """
    {
        "type": "object",
        "properties": {
            "artist": {
                "description": "The artist name to search for",
                "type": "string"
            },
            "title": {
                "description": "The song title to search for",
                "type": "string"
            },
            "storefront": {
                "description": "Optional Apple Music storefront (default: fr)",
                "type": "string"
            }
        },
        "required": ["artist", "title"]
    }
    """

let searchByArtistAndTitleTool = MCPTool<SearchByArtistAndTitleInput, String>(
    name: "searchByArtistAndTitle",
    description: "Search the Apple Music catalog by both artist name and song title",
    inputSchema: searchByArtistAndTitleToolSchema,
    converter: { params in
        let artist = try MCPTool<String, String>.extractParameter(params, name: "artist")
        let title = try MCPTool<String, String>.extractParameter(params, name: "title")
        let storefront = try? MCPTool<String, String>.extractParameter(params, name: "storefront")

        return SearchByArtistAndTitleInput(
            artist: artist,
            title: title,
            storefront: storefront
        )
    },
    body: { input async throws -> String in
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let results = try await client.searchByArtistAndTitle(
            artist: input.artist,
            title: input.title
        )

        // Convert results to JSON string
        let encoder = JSONEncoder()
        // encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(results)
        return String(decoding: data, as: UTF8.self)
    }
)

// Get Song Details Tool
struct GetSongDetailsInput: Codable {
    let id: String
    let storefront: String?
}

let getSongDetailsToolSchema = """
    {
        "type": "object",
        "properties": {
            "id": {
                "description": "The Apple Music song ID",
                "type": "string"
            },
            "storefront": {
                "description": "Optional Apple Music storefront (default: fr)",
                "type": "string"
            }
        },
        "required": ["id"]
    }
    """

let getSongDetailsTool = MCPTool<GetSongDetailsInput, String>(
    name: "getSongDetails",
    description: "Get detailed information about a specific song by ID",
    inputSchema: getSongDetailsToolSchema,
    converter: { params in
        let id = try MCPTool<String, String>.extractParameter(params, name: "id")
        let storefront = try? MCPTool<String, String>.extractParameter(params, name: "storefront")

        return GetSongDetailsInput(
            id: id,
            storefront: storefront
        )
    },
    body: { input async throws -> String in
        // Use default token generation from AppleMusicKit
        let client = try await AppleMusicClient(storefront: input.storefront ?? "fr")

        let songDetails = try await client.getSongDetails(id: input.id)

        // Convert results to JSON string
        let encoder = JSONEncoder()
        // encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(songDetails)
        return String(decoding: data, as: UTF8.self)
    }
)
