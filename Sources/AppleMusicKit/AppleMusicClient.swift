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
    let endpoint = "/catalog/\(storefront)/search?types=artists&term=\(encodeTerm(artistName))&limit=\(limit)"
    return try await performRequest(endpoint: endpoint)
  }

  /// Search for music by song title
  /// - Parameters:
  ///   - title: The title of the song to search for
  ///   - limit: Maximum number of results to return (default: 25)
  /// - Returns: Search response containing results
  public func searchByTitle(_ title: String, limit: Int = 25) async throws -> SearchResponse {
    let endpoint = "/catalog/\(storefront)/search?types=songs&term=\(encodeTerm(title))&limit=\(limit)"
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
    let query = "\(encodeTerm(artist)) \(encodeTerm(title))"
    let endpoint = "/catalog/\(storefront)/search?types=artists,songs&term=\(query)&limit=\(limit)"
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
    let endpoint = "/me/library/playlists?limit=\(limit)&term=\(encodeTerm(name))"
    return try await performRequest(endpoint: endpoint, userToken: userToken)
  }

  /// Get storefront charts playlists
  /// - Parameters:
  ///   - chartType: Type of chart (optional)
  ///   - genre: Genre filter (optional)
  ///   - limit: Maximum number of results to return (default: 25)
  ///   - offset: Offset for pagination (default: 0)
  /// - Returns: Storefront charts response
  public func getStorefrontCharts(
    chartType: ChartType? = nil,
    genre: ChartGenre? = nil,
    limit: Int = 25,
    offset: Int = 0
  ) async throws -> StorefrontChartsResponse {
    var queryItems = [
      "filter[storefront-chart]=\(storefront)", "limit=\(limit)", "offset=\(offset)",
    ]

    if let chartType = chartType {
      queryItems.append("filter[chart]=\(chartType.rawValue)")
    }

    if let genre = genre, genre != .all {
      queryItems.append("filter[genre]=\(genre.rawValue)")
    }

    let queryString = queryItems.joined(separator: "&")
    let endpoint = "/catalog/\(storefront)/playlists?\(queryString)"

    return try await performRequest(endpoint: endpoint)
  }

  /// Search for storefront playlists by name
  /// - Parameters:
  ///   - name: The name to search for
  ///   - limit: Maximum number of results to return (default: 25)
  /// - Returns: Search response containing playlists
  public func searchStorefrontPlaylists(name: String, limit: Int = 25) async throws
    -> SearchResponse
  {
    let endpoint = "/catalog/\(storefront)/search?types=playlists&term=\(name)&limit=\(limit)"
    return try await performRequest(endpoint: endpoint)
  }

  /// Get details for a specific storefront playlist by ID
  /// - Parameter id: The playlist ID
  /// - Returns: Playlist details
  public func getStorefrontPlaylistDetails(id: String) async throws -> Playlist {
    let endpoint = "/catalog/\(storefront)/playlists/\(id)"
    let response: PlaylistResponse = try await performRequest(endpoint: endpoint)

    guard let playlist = response.data.first else {
      throw AppleMusicError.noDataReturned
    }

    return playlist
  }

  // MARK: - Private Methods

  private func performRequest<T: Decodable>(endpoint: String, userToken: String? = nil) async throws
    -> T
  {

    guard let url = URL(string: baseURL + endpoint) else {
      throw AppleMusicError.invalidURL
    }

    print("=========== ")
    print("Request URL: \(url)")
    print("=========== ")

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

  // private func encodeParameter(_ parameter: String) throws -> String {
  //   // Define a custom character set that allows everything except ',' and '&'
  //   var allowed = CharacterSet.urlQueryAllowed
  //   allowed.remove(charactersIn: ",& =+")
  //   guard let encodedParameter = parameter.addingPercentEncoding(withAllowedCharacters: allowed) else {
  //     throw AppleMusicError.invalidEncoding
  //   }    
  //   return encodedParameter
  // }
  private func encodeTerm(_ term: String) -> String {
    // https://developer.apple.com/documentation/applemusicapi/search-for-catalog-resources-(by-type)
    // encode the search term with + between words, remove commas, ampersands, and equals signs
    var encodedTerm: String!
    encodedTerm = term.replacingOccurrences(of: ",", with: " ")
    encodedTerm = encodedTerm.replacingOccurrences(of: "&", with: " ")
    encodedTerm = encodedTerm.replacingOccurrences(of: "=", with: " ")
    encodedTerm = encodedTerm.replacingOccurrences(of: " ", with: "+")
    return encodedTerm
  }
}
