import Foundation

/// Helper class for generating Apple Music API tokens using external scripts
public class ExternalTokenGenerator {

    /// Execute a shell command to generate a JWT token using the provided script
    /// - Parameters:
    ///   - scriptPath: Path to the JWT generation script
    ///   - privateKeyPath: Path to the private key file
    /// - Returns: JWT token string
    public static func generateTokenUsingScript(
        scriptPath: String,
        privateKeyPath: String
    ) throws
        -> String
    {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptPath, privateKeyPath]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw AppleMusicError.jwtEncodingError
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: outputData, encoding: .utf8) else {
            throw AppleMusicError.jwtEncodingError
        }

        // Extract the JWT token from the output
        if let jwtRange = output.range(of: "JWT: ") {
            let tokenStart = jwtRange.upperBound
            let token = String(output[tokenStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return token
        } else {
            throw AppleMusicError.jwtEncodingError
        }
    }

    /// Generate a token using the Node.js script
    /// - Parameters:
    ///   - scriptPath: Path to the Node.js script
    /// - Returns: JWT token string
    public static func generateTokenUsingNodeScript(scriptPath: String) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["node", scriptPath]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw AppleMusicError.jwtEncodingError
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: outputData, encoding: .utf8) else {
            throw AppleMusicError.jwtEncodingError
        }

        // Extract the JWT token from the output
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
