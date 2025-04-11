import Foundation

/// Secret configuration for Apple Music API authentication
public struct Secret: Codable, Sendable {
  /// The private key in PEM format
  public let privateKey: String

  /// The team ID from your Apple Developer account
  public let teamId: String

  /// The key ID from your Apple Developer account
  public let keyId: String

  /// Initialize a new Secret
  /// - Parameters:
  ///   - privateKey: The private key in PEM format
  ///   - teamId: The team ID from your Apple Developer account
  ///   - keyId: The key ID from your Apple Developer account
  public init(privateKey: String, teamId: String, keyId: String) {
    self.privateKey = privateKey
    self.teamId = teamId
    self.keyId = keyId
  }
}

// TODO: add your secret here
// Default secret for development purposes
// Note: Replace with your own credentials for production use
// https://developer.apple.com/help/account/capabilities/create-a-media-identifier-and-private-key/
// The rest of the code generates token as described here
// https://developer.apple.com/documentation/applemusicapi/generating-developer-tokens

// public let defaultSecret = Secret(
//   privateKey: """
//     -----BEGIN PRIVATE KEY-----
//     M....Wl
//     -----END PRIVATE KEY-----
//     """,
//   teamId: "1234567890",
//   keyId: "1234567890"
// )
