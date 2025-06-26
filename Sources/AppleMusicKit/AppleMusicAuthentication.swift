import Crypto
import Foundation
import JWTKit

/// Factory for generating and validating Apple Music API tokens
public struct AppleMusicTokenFactory: Sendable {

    /// Apple Music JWT token payload
    public struct AppleMusicToken: JWTKit.JWTPayload, Equatable {

        public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
            try self.exp.verifyNotExpired()
        }

        /// The issuer (iss) registered claim key, whose value is your 10-character Team ID
        public let iss: IssuerClaim

        /// The issued at (iat) registered claim key, whose value indicates the time at which the token was generated
        public let iat: IssuedAtClaim

        /// The expiration time (exp) registered claim key, whose value must not be greater than 15777000 (6 months in seconds)
        public let exp: ExpirationClaim
    }

    private let secret: Secret
    private let expirationInterval: TimeInterval

    /// Initialize a new token factory
    /// - Parameters:
    ///   - secret: The secret containing private key, team ID, and key ID
    ///   - expirationInterval: Token expiration interval in seconds (default: 1 day)
    public init(secret: Secret, expirationInterval: TimeInterval = 24 * 60 * 60) {
        self.secret = secret
        self.expirationInterval = expirationInterval
    }

    /// Generate a new Apple Music API developer token
    /// - Returns: JWT token string
    public func generateToken() async throws -> String {
        let keyCollection = JWTKit.JWTKeyCollection()

        // Create the ES256 signer
        let privateKey = try JWTKit.ECDSA.PrivateKey<P256>(pem: secret.privateKey)

        // Add the signer to the collection with the key ID
        await keyCollection.add(ecdsa: privateKey, kid: JWTKit.JWKIdentifier(string: secret.keyId))

        let payload = AppleMusicToken(
            iss: .init(value: secret.teamId),
            iat: .init(value: .now),
            exp: .init(value: .init(timeIntervalSinceNow: expirationInterval))
        )

        // Sign the payload
        return try await keyCollection.sign(
            payload,
            kid: JWTKit.JWKIdentifier(string: secret.keyId)
        )
    }

    /// Validate an existing Apple Music API token
    /// - Parameter token: The token to validate
    /// - Returns: True if the token is valid, false otherwise
    public func validateToken(_ token: String?) async -> Bool {
        guard let token else {
            return false
        }

        do {
            let keyCollection = JWTKit.JWTKeyCollection()

            // Create the ES256 signer
            let privateKey = try JWTKit.ECDSA.PrivateKey<P256>(pem: secret.privateKey)

            // Add the signer to the collection with the key ID
            await keyCollection.add(
                ecdsa: privateKey,
                kid: JWTKit.JWKIdentifier(string: secret.keyId)
            )

            // Verify the token
            let _ = try await keyCollection.verify(token, as: AppleMusicToken.self)
            return true
        } catch {
            return false
        }
    }
}
