import Foundation

// MARK: - Search Response Models

/// Main response structure for search results
public struct SearchResponse: Codable {
  public let results: SearchResults
}

/// Container for search results by type
public struct SearchResults: Codable {
  public let songs: SongResults?
  public let artists: ArtistResults?
  public let albums: AlbumResults?
  public let playlists: PlaylistResults?

  public init(
    songs: SongResults? = nil, artists: ArtistResults? = nil, albums: AlbumResults? = nil,
    playlists: PlaylistResults? = nil
  ) {
    self.songs = songs
    self.artists = artists
    self.albums = albums
    self.playlists = playlists
  }
}

/// Container for song search results
public struct SongResults: Codable {
  public let data: [Song]
  public let href: String
  public let next: String?
}

/// Container for artist search results
public struct ArtistResults: Codable {
  public let data: [Artist]
  public let href: String
  public let next: String?
}

/// Container for album search results
public struct AlbumResults: Codable {
  public let data: [Album]
  public let href: String
  public let next: String?
}

/// Container for playlist search results
public struct PlaylistResults: Codable {
  public let data: [Playlist]
  public let href: String
  public let next: String?
}

// MARK: - Song Response Model

/// Response structure for song details
public struct SongResponse: Codable {
  public let data: [Song]
}

// MARK: - Core Data Models

/// Song model
public struct Song: Codable, Identifiable {
  public let id: String
  public let type: String
  public let href: String
  public let attributes: SongAttributes?
  public let relationships: SongRelationships?

  public init(
    id: String, type: String, href: String, attributes: SongAttributes? = nil,
    relationships: SongRelationships? = nil
  ) {
    self.id = id
    self.type = type
    self.href = href
    self.attributes = attributes
    self.relationships = relationships
  }
}

/// Song attributes
public struct SongAttributes: Codable {
  public let albumName: String?
  public let artistName: String
  public let artwork: Artwork?
  public let composerName: String?
  public let discNumber: Int?
  public let durationInMillis: Int?
  public let genreNames: [String]
  public let isrc: String?
  public let name: String
  public let previews: [Preview]?
  public let releaseDate: String?
  public let trackNumber: Int?
  public let url: String?
}

/// Song relationships
public struct SongRelationships: Codable {
  public let albums: Relationship<Album>?
  public let artists: Relationship<Artist>?
}

/// Artist model
public struct Artist: Codable, Identifiable {
  public let id: String
  public let type: String
  public let href: String
  public let attributes: ArtistAttributes?
  public let relationships: ArtistRelationships?

  public init(
    id: String, type: String, href: String, attributes: ArtistAttributes? = nil,
    relationships: ArtistRelationships? = nil
  ) {
    self.id = id
    self.type = type
    self.href = href
    self.attributes = attributes
    self.relationships = relationships
  }
}

/// Artist attributes
public struct ArtistAttributes: Codable {
  public let genreNames: [String]?
  public let name: String
  public let url: String?
  public let artwork: Artwork?
}

/// Artist relationships
public struct ArtistRelationships: Codable {
  public let albums: Relationship<Album>?
}

/// Album model
public struct Album: Codable, Identifiable {
  public let id: String
  public let type: String
  public let href: String
  public let attributes: AlbumAttributes?
  public let relationships: AlbumRelationships?

  public init(
    id: String, type: String, href: String, attributes: AlbumAttributes? = nil,
    relationships: AlbumRelationships? = nil
  ) {
    self.id = id
    self.type = type
    self.href = href
    self.attributes = attributes
    self.relationships = relationships
  }
}

/// Album attributes
public struct AlbumAttributes: Codable {
  public let artistName: String
  public let artwork: Artwork?
  public let contentRating: String?
  public let copyright: String?
  public let editorialNotes: EditorialNotes?
  public let genreNames: [String]
  public let isComplete: Bool?
  public let isSingle: Bool?
  public let name: String
  public let releaseDate: String?
  public let trackCount: Int?
  public let url: String?
}

/// Album relationships
public struct AlbumRelationships: Codable {
  public let artists: Relationship<Artist>?
  public let tracks: Relationship<Song>?
}

// MARK: - Common Models

/// Generic relationship container
public struct Relationship<T: Codable>: Codable {
  public let href: String?
  public let data: [T]?
  public let next: String?
}

/// Artwork model
public struct Artwork: Codable {
  public let width: Int?
  public let height: Int?
  public let url: String
  public let bgColor: String?
  public let textColor1: String?
  public let textColor2: String?
  public let textColor3: String?
  public let textColor4: String?

  /// Get the artwork URL with specified dimensions
  /// - Parameters:
  ///   - width: Desired width
  ///   - height: Desired height
  /// - Returns: URL string with the specified dimensions
  public func getURL(width: Int, height: Int) -> String {
    return url.replacingOccurrences(of: "{w}", with: "\(width)")
      .replacingOccurrences(of: "{h}", with: "\(height)")
  }
}

/// Preview model for song previews
public struct Preview: Codable {
  public let url: String
}

/// Editorial notes
public struct EditorialNotes: Codable {
  public let standard: String?
  public let short: String?
}

// MARK: - Error Types

/// Apple Music API errors
public enum AppleMusicError: Error {
  case invalidURL
  case invalidEncoding
  case invalidResponse
  case httpError(statusCode: Int)
  case decodingError(Error)
  case noDataReturned
  case privateKeyNotFound
  case privateKeyInvalid
  case jwtEncodingError
  case notImplemented(String)

  public var localizedDescription: String {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .invalidEncoding:
      return "Invalid URL encoding"
    case .invalidResponse:
      return "Invalid response from server"
    case .httpError(let statusCode):
      return "HTTP error: \(statusCode)"
    case .decodingError(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    case .noDataReturned:
      return "No data returned from the server"
    case .privateKeyNotFound:
      return "Private key file not found"
    case .privateKeyInvalid:
      return "Invalid private key format"
    case .jwtEncodingError:
      return "Error encoding JWT token"
    case .notImplemented(let message):
      return "Not implemented: \(message)"
    }
  }
}
