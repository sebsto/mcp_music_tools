import Foundation
import Testing

@testable import OpenURLKit

@Suite("OpenURLKit Tests")
struct OpenURLKitTests {
  @Test("Valid URL parsing")
  func testValidURL() throws {
    // This is a basic test that doesn't actually open a URL
    // but checks that the URL parsing works correctly
    let validURLString = "https://aws.amazon.com"
    #expect(URL(string: validURLString) != nil)
  }

  @Test("Invalid URL parsing")
  func testInvalidURL() throws {
    // Test that invalid URLs are properly rejected
    let invalidURLString = "http://invalid url with spaces"
    #expect(URL(string: invalidURLString) == nil)
  }

  @Test("URLOpenerError equality")
  func testURLOpenerErrorEquality() throws {
    // Test that URLOpenerError conforms to Equatable correctly
    #expect(URLOpenerError.invalidURL == URLOpenerError.invalidURL)
    #expect(URLOpenerError.failedToOpenURL == URLOpenerError.failedToOpenURL)
    #expect(URLOpenerError.unsupportedPlatform == URLOpenerError.unsupportedPlatform)
    #expect(URLOpenerError.invalidURL != URLOpenerError.failedToOpenURL)
  }

  @Test("URLOpenerError descriptions")
  func testURLOpenerErrorDescription() throws {
    // Test that error descriptions are provided
    #expect(URLOpenerError.invalidURL.errorDescription != nil)
    #expect(URLOpenerError.failedToOpenURL.errorDescription != nil)
    #expect(URLOpenerError.unsupportedPlatform.errorDescription != nil)
  }
}
