import Foundation

// MARK: - Playlist Response Models

/// Response structure for user playlists
public struct UserPlaylistsResponse: Codable {
    public let data: [Playlist]
    public let next: String?
}

/// Response structure for a single playlist
public struct PlaylistResponse: Codable {
    public let data: [Playlist]
}

// MARK: - Playlist Model

/// Playlist model
public struct Playlist: Codable, Identifiable {
    public let id: String
    public let type: String
    public let href: String
    public let attributes: PlaylistAttributes?
    public let relationships: PlaylistRelationships?
    
    public init(
        id: String, 
        type: String, 
        href: String, 
        attributes: PlaylistAttributes? = nil,
        relationships: PlaylistRelationships? = nil
    ) {
        self.id = id
        self.type = type
        self.href = href
        self.attributes = attributes
        self.relationships = relationships
    }
}

/// Playlist attributes
public struct PlaylistAttributes: Codable {
    public let name: String
    public let description: EditorialNotes?
    public let playlistType: String?
    public let url: String?
    public let artwork: Artwork?
    public let isPublic: Bool?
    public let trackCount: Int?
    public let lastModifiedDate: String?
    public let dateAdded: String?
}

/// Playlist relationships
public struct PlaylistRelationships: Codable {
    public let tracks: Relationship<Song>?
    public let curator: Relationship<Curator>?
}

/// Curator model
public struct Curator: Codable, Identifiable {
    public let id: String
    public let type: String
    public let href: String
    public let attributes: CuratorAttributes?
    
    public init(
        id: String,
        type: String,
        href: String,
        attributes: CuratorAttributes? = nil
    ) {
        self.id = id
        self.type = type
        self.href = href
        self.attributes = attributes
    }
}

/// Curator attributes
public struct CuratorAttributes: Codable {
    public let name: String
    public let url: String?
    public let artwork: Artwork?
}
