import Foundation

/// Errors that can occur when opening URLs
public enum URLOpenerError: Error, LocalizedError, Equatable {
  case invalidURL
  case failedToOpenURL
  case unsupportedPlatform

  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "The provided URL is invalid"
    case .failedToOpenURL:
      return "Failed to open the URL in the default browser"
    case .unsupportedPlatform:
      return "URL opening is not supported on this platform"
    }
  }
}

/// A simple library for opening URLs in the default browser
public struct URLOpener {
  /// Opens the specified URL in the default browser using system commands
  /// - Parameter url: The URL to open
  /// - Throws: An error if the URL cannot be opened
  public static func open(_ url: URL) throws {
    let process = Process()

    #if os(macOS)
      process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    #elseif os(Linux)
      process.executableURL = URL(fileURLWithPath: "/usr/bin/xdg-open")
    #else
      throw URLOpenerError.unsupportedPlatform
    #endif

    process.arguments = [url.absoluteString]

    do {
      try process.run()
      process.waitUntilExit()

      if process.terminationStatus != 0 {
        throw URLOpenerError.failedToOpenURL
      }
    } catch {
      throw URLOpenerError.failedToOpenURL
    }
  }

  /// Opens the specified URL string in the default browser
  /// - Parameter urlString: The URL string to open
  /// - Throws: An error if the URL is invalid or cannot be opened
  public static func open(_ urlString: String) throws {
    guard let url = URL(string: urlString) else {
      throw URLOpenerError.invalidURL
    }
    try open(url)
  }
}
