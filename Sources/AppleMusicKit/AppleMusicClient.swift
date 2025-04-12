import Foundation
import JWTKit

/// Protocol for URL session functionality
public protocol URLSessionProtocol {
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// Make URLSession conform to our protocol
extension URLSession: URLSessionProtocol {}

/// Main client for interacting with the Apple Music API
public class AppleMusicClient {
  // MARK: - Properties

  private let baseURL = "https://api.music.apple.com/v1"
  private let developerToken: String
  private let storefront: String
  private let session: URLSessionProtocol

  // MARK: - Initialization

  /// Initialize the Apple Music API client
  /// - Parameters:
  ///   - developerToken: The JWT developer token for Apple Music API
  ///   - storefront: The storefront to use (e.g., "us", "fr")
  ///   - session: URLSessionProtocol to use for network requests (defaults to shared session)
  public init(
    developerToken: String, storefront: String, session: URLSessionProtocol = URLSession.shared
  ) {
    self.developerToken = developerToken
    self.storefront = storefront
    self.session = session
  }

  /// Initialize the Apple Music API client using a Secret
  /// - Parameters:
  ///   - secret: The Secret containing private key, team ID, and key ID
  ///   - storefront: The storefront to use (e.g., "us", "fr")
  ///   - session: URLSessionProtocol to use for network requests (defaults to shared session)
  public convenience init(
    secret: Secret? = nil, storefront: String, session: URLSessionProtocol = URLSession.shared
  )
    async throws
  {
    let tokenFactory: AppleMusicTokenFactory
    if let secret {
      tokenFactory = AppleMusicTokenFactory(secret: secret)
    } else {
      tokenFactory = AppleMusicTokenFactory(secret: defaultSecret)
    }

    let token = try await tokenFactory.generateToken()
    self.init(developerToken: token, storefront: storefront, session: session)

  }

  // MARK: - Public Methods

  /// Search for music by artist name
  /// - Parameters:
  ///   - artistName: The name of the artist to search for
  ///   - limit: Maximum number of results to return (default: 25)
  /// - Returns: Search response containing results
  public func searchByArtist(_ artistName: String, limit: Int = 25) async throws -> SearchResponse {
    let encodedArtist =
      artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artistName
    let endpoint =
      "/catalog/\(storefront)/search?types=artists&term=\(encodedArtist)&limit=\(limit)"

    return try await performRequest(endpoint: endpoint)
  }

  /// Search for music by song title
  /// - Parameters:
  ///   - title: The title of the song to search for
  ///   - limit: Maximum number of results to return (default: 25)
  /// - Returns: Search response containing results
  public func searchByTitle(_ title: String, limit: Int = 25) async throws -> SearchResponse {
    let encodedTitle =
      title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
    let endpoint =
      "/catalog/\(storefront)/search?types=songs&term=\(encodedTitle)&limit=\(limit)"

    return try await performRequest(endpoint: endpoint)
  }

  /// Search for music by both artist and title
  /// - Parameters:
  ///   - artist: The name of the artist
  ///   - title: The title of the song
  ///   - limit: Maximum number of results to return (default: 25)
  /// - Returns: Search response containing results
  public func searchByArtistAndTitle(artist: String, title: String, limit: Int = 25) async throws
    -> SearchResponse
  {
    let encodedQuery =
      "\(artist) \(title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      ?? "\(artist) \(title)"
    let endpoint =
      "/catalog/\(storefront)/search?types=artists,songs&term=\(encodedQuery)&limit=\(limit)"

    return try await performRequest(endpoint: endpoint)
  }

  /// Get details for a specific song by ID
  /// - Parameter id: The Apple Music song ID
  /// - Returns: Song details
  public func getSongDetails(id: String) async throws -> Song {
    let endpoint = "/catalog/\(storefront)/songs/\(id)"
    let response: SongResponse = try await performRequest(endpoint: endpoint)

    guard let song = response.data.first else {
      throw AppleMusicError.noDataReturned
    }

    return song
  }

  /// Get the user's library playlists
  /// - Parameters:
  ///   - limit: Maximum number of results to return (default: 25)
  ///   - offset: Offset for pagination (default: 0)
  ///   - userToken: User token for authentication (required for user library access)
  /// - Returns: User playlists response
  public func getUserPlaylists(limit: Int = 25, offset: Int = 0, userToken: String) async throws
    -> UserPlaylistsResponse
  {
    let endpoint = "/me/library/playlists?limit=\(limit)&offset=\(offset)"
    return try await performRequest(endpoint: endpoint, userToken: userToken)
  }

  /// Get details for a specific user playlist by ID
  /// - Parameters:
  ///   - id: The playlist ID
  ///   - userToken: User token for authentication (required for user library access)
  /// - Returns: Playlist details
  public func getUserPlaylistDetails(id: String, userToken: String) async throws -> Playlist {
    let endpoint = "/me/library/playlists/\(id)"
    let response: PlaylistResponse = try await performRequest(
      endpoint: endpoint, userToken: userToken)

    guard let playlist = response.data.first else {
      throw AppleMusicError.noDataReturned
    }

    return playlist
  }

  /// Search for user playlists by name
  /// - Parameters:
  ///   - name: The name to search for
  ///   - limit: Maximum number of results to return (default: 25)
  ///   - userToken: User token for authentication (required for user library access)
  /// - Returns: User playlists response
  public func searchUserPlaylists(name: String, limit: Int = 25, userToken: String) async throws
    -> UserPlaylistsResponse
  {
    let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
    let endpoint = "/me/library/playlists?limit=\(limit)&term=\(encodedName)"
    return try await performRequest(endpoint: endpoint, userToken: userToken)
  }

  // MARK: - Private Methods

  private func performRequest<T: Decodable>(endpoint: String, userToken: String? = nil) async throws
    -> T
  {
    guard let url = URL(string: baseURL + endpoint) else {
      throw AppleMusicError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")

    // Add user token if provided (required for user library access)
    if let userToken = userToken {
      request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
    }

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AppleMusicError.invalidResponse
    }

    guard 200...299 ~= httpResponse.statusCode else {
      throw AppleMusicError.httpError(statusCode: httpResponse.statusCode)
    }

    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode(T.self, from: data)
    } catch {
      throw AppleMusicError.decodingError(error)
    }
  }
}
