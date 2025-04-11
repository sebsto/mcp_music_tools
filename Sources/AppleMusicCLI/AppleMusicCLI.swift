import AppleMusicKit
import ArgumentParser
import Foundation
import JWTKit

@main
struct AppleMusicSearch: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "AppleMusicCLI",
    abstract: "Search the Apple Music catalog",
    subcommands: [
      SearchByArtist.self, SearchByTitle.self, SearchByBoth.self, GetSongDetails.self,
      GenerateToken.self,
    ],
    defaultSubcommand: SearchByArtist.self
  )
}

// MARK: - Search by Artist

struct SearchByArtist: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "artist",
    abstract: "Search for music by artist name"
  )

  @Option(name: .shortAndLong, help: "Apple Music developer token (optional)")
  var token: String?

  @Option(name: [.customShort("f"), .long], help: "Storefront to search in (e.g., us, fr)")
  var storefront: String = "us"

  @Option(name: .shortAndLong, help: "Maximum number of results")
  var limit: Int = 5

  @Argument(help: "Artist name to search for")
  var artist: String

  mutating func run() async throws {
    print("Searching for artist: \(artist)")

    let developerToken = try await getDeveloperToken()
    let client = AppleMusicClient(developerToken: developerToken, storefront: storefront)

    let searchResponse = try await client.searchByArtist(artist, limit: limit)

    if let artists = searchResponse.results.artists {
      print("\nFound \(artists.data.count) artists:")
      for (index, artist) in artists.data.enumerated() {
        print("\n[\(index + 1)] \(artist.attributes?.name ?? "Unknown")")
        if let genres = artist.attributes?.genreNames, !genres.isEmpty {
          print("Genres: \(genres.joined(separator: ", "))")
        }
        if let url = artist.attributes?.url {
          print("URL: \(url)")
        }
      }
    } else {
      print("No artists found.")
    }
  }

  private func getDeveloperToken() async throws -> String {
    if let token = token {
      return token
    } else {
      // Use default secret if no token is provided
      let tokenFactory = AppleMusicTokenFactory(secret: defaultSecret)
      return try await tokenFactory.generateToken()
    }
  }
}

// MARK: - Search by Title

struct SearchByTitle: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "title",
    abstract: "Search for music by song title"
  )

  @Option(name: .shortAndLong, help: "Apple Music developer token (optional)")
  var token: String?

  @Option(name: [.customShort("f"), .long], help: "Storefront to search in (e.g., us, fr)")
  var storefront: String = "us"

  @Option(name: .shortAndLong, help: "Maximum number of results")
  var limit: Int = 5

  @Argument(help: "Song title to search for")
  var title: String

  mutating func run() async throws {
    print("Searching for song title: \(title)")

    let developerToken = try await getDeveloperToken()
    let client = AppleMusicClient(developerToken: developerToken, storefront: storefront)

    let searchResponse = try await client.searchByTitle(title, limit: limit)

    if let songs = searchResponse.results.songs {
      print("\nFound \(songs.data.count) songs:")
      for (index, song) in songs.data.enumerated() {
        print("\n[\(index + 1)] \(song.attributes?.name ?? "Unknown")")
        print("ID: \(song.id)")
        print("Artist: \(song.attributes?.artistName ?? "Unknown")")
        print("Album: \(song.attributes?.albumName ?? "Unknown")")
        if let duration = song.attributes?.durationInMillis {
          let seconds = duration / 1000
          print("Duration: \(seconds / 60):\(String(format: "%02d", seconds % 60))")
        }
        if let url = song.attributes?.url {
          print("URL: \(url)")
        }
      }
    } else {
      print("No songs found.")
    }
  }

  private func getDeveloperToken() async throws -> String {
    if let token = token {
      return token
    } else {
      // Use default secret if no token is provided
      let tokenFactory = AppleMusicTokenFactory(secret: defaultSecret)
      return try await tokenFactory.generateToken()
    }
  }
}

// MARK: - Search by Both Artist and Title

struct SearchByBoth: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "search",
    abstract: "Search for music by both artist and title"
  )

  @Option(name: .shortAndLong, help: "Apple Music developer token (optional)")
  var token: String?

  @Option(name: [.customShort("f"), .long], help: "Storefront to search in (e.g., us, fr)")
  var storefront: String = "us"

  @Option(name: .shortAndLong, help: "Maximum number of results")
  var limit: Int = 5

  @Option(name: [.customShort("a"), .long], help: "Artist name")
  var artist: String

  @Option(name: [.customShort("T"), .long], help: "Song title")
  var title: String

  mutating func run() async throws {
    print("Searching for artist: \(artist), title: \(title)")

    let developerToken = try await getDeveloperToken()
    let client = AppleMusicClient(developerToken: developerToken, storefront: storefront)

    let searchResponse = try await client.searchByArtistAndTitle(
      artist: artist, title: title, limit: limit)

    if let songs = searchResponse.results.songs {
      print("\nFound \(songs.data.count) songs:")
      for (index, song) in songs.data.enumerated() {
        print("\n[\(index + 1)] \(song.attributes?.name ?? "Unknown")")
        print("ID: \(song.id)")
        print("Artist: \(song.attributes?.artistName ?? "Unknown")")
        print("Album: \(song.attributes?.albumName ?? "Unknown")")
        if let duration = song.attributes?.durationInMillis {
          let seconds = duration / 1000
          print("Duration: \(seconds / 60):\(String(format: "%02d", seconds % 60))")
        }
        if let url = song.attributes?.url {
          print("URL: \(url)")
        }
      }
    } else {
      print("No songs found.")
    }

    if let artists = searchResponse.results.artists {
      print("\nFound \(artists.data.count) artists:")
      for (index, artist) in artists.data.enumerated() {
        print("\n[\(index + 1)] \(artist.attributes?.name ?? "Unknown")")
        if let genres = artist.attributes?.genreNames, !genres.isEmpty {
          print("Genres: \(genres.joined(separator: ", "))")
        }
        if let url = artist.attributes?.url {
          print("URL: \(url)")
        }
      }
    }
  }

  private func getDeveloperToken() async throws -> String {
    if let token = token {
      return token
    } else {
      // Use default secret if no token is provided
      let tokenFactory = AppleMusicTokenFactory(secret: defaultSecret)
      return try await tokenFactory.generateToken()
    }
  }
}

// MARK: - Get Song Details

struct GetSongDetails: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "song",
    abstract: "Get details for a specific song by ID"
  )

  @Option(name: .shortAndLong, help: "Apple Music developer token (optional)")
  var token: String?

  @Option(name: [.customShort("f"), .long], help: "Storefront to search in (e.g., us, fr)")
  var storefront: String = "us"

  @Argument(help: "Song ID")
  var songId: String

  mutating func run() async throws {
    print("Getting details for song ID: \(songId)")

    let developerToken = try await getDeveloperToken()
    let client = AppleMusicClient(developerToken: developerToken, storefront: storefront)

    let song = try await client.getSongDetails(id: songId)

    print("\nSong Details:")
    print("Title: \(song.attributes?.name ?? "Unknown")")
    print("Artist: \(song.attributes?.artistName ?? "Unknown")")
    print("Album: \(song.attributes?.albumName ?? "Unknown")")

    if let genreNames = song.attributes?.genreNames, !genreNames.isEmpty {
      print("Genres: \(genreNames.joined(separator: ", "))")
    }

    if let duration = song.attributes?.durationInMillis {
      let seconds = duration / 1000
      print("Duration: \(seconds / 60):\(String(format: "%02d", seconds % 60))")
    }

    if let releaseDate = song.attributes?.releaseDate {
      print("Release Date: \(releaseDate)")
    }

    if let isrc = song.attributes?.isrc {
      print("ISRC: \(isrc)")
    }

    if let url = song.attributes?.url {
      print("URL: \(url)")
    }

    if let previews = song.attributes?.previews, !previews.isEmpty {
      print("Preview URL: \(previews[0].url)")
    }
  }

  private func getDeveloperToken() async throws -> String {
    if let token = token {
      return token
    } else {
      // Use default secret if no token is provided
      let tokenFactory = AppleMusicTokenFactory(secret: defaultSecret)
      return try await tokenFactory.generateToken()
    }
  }
}

// MARK: - Generate Token

struct GenerateToken: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "token",
    abstract: "Generate an Apple Music developer token"
  )

  @Option(name: [.customShort("p"), .long], help: "Path to token generation script")
  var scriptPath: String?

  @Option(name: [.customShort("k"), .long], help: "Path to private key file")
  var keyPath: String?

  @Option(name: .shortAndLong, help: "Team ID from Apple Developer account")
  var teamId: String?

  @Option(name: [.customShort("i"), .long], help: "Key ID from Apple Developer account")
  var keyId: String?

  mutating func run() async throws {
    let token: String

    if let scriptPath = scriptPath {
      if scriptPath.hasSuffix(".js") {
        token = try ExternalTokenGenerator.generateTokenUsingNodeScript(
          scriptPath: scriptPath)
      } else if let keyPath = keyPath {
        token = try ExternalTokenGenerator.generateTokenUsingScript(
          scriptPath: scriptPath, privateKeyPath: keyPath)
      } else {
        throw ValidationError("When using a bash script, you must provide --key-path")
      }
    } else if let teamId = teamId, let keyId = keyId, let keyPath = keyPath {
      let privateKey = try String(contentsOfFile: keyPath, encoding: .utf8)
      let secret = Secret(privateKey: privateKey, teamId: teamId, keyId: keyId)
      let tokenFactory = AppleMusicTokenFactory(secret: secret)
      token = try await tokenFactory.generateToken()
    } else {
      // Default behavior is to use the default secret
      let tokenFactory = AppleMusicTokenFactory(secret: defaultSecret)
      token = try await tokenFactory.generateToken()
    }

    print("Generated Token:")
    print(token)
  }
}
