import XCTest
@testable import AppleMusicKit
import Foundation

// Mock implementation of URLSessionProtocol for testing
class MockURLSession: URLSessionProtocol {
    var mockResponse: (Data, URLResponse) = (Data(), URLResponse())
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return mockResponse
    }
}

final class AppleMusicKitTests: XCTestCase {
    // Mock developer token for testing
    let mockToken = "mock_developer_token"
    let mockStorefront = "us"
    
    func testSearchByArtist() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(developerToken: mockToken, storefront: mockStorefront, session: session)
        
        // Set up the mock response
        let mockResponseData = """
        {
            "results": {
                "artists": {
                    "data": [
                        {
                            "id": "123456789",
                            "type": "artists",
                            "href": "/v1/catalog/us/artists/123456789",
                            "attributes": {
                                "name": "Test Artist",
                                "genreNames": ["Pop", "Rock"],
                                "url": "https://music.apple.com/us/artist/test-artist/123456789"
                            }
                        }
                    ],
                    "href": "/v1/catalog/us/search?term=test&types=artists",
                    "next": null
                }
            }
        }
        """.data(using: .utf8)!
        
        session.mockResponse = (mockResponseData, HTTPURLResponse(url: URL(string: "https://api.music.apple.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        // Perform the search
        let result = try await client.searchByArtist("Test Artist")
        
        // Verify the results
        XCTAssertNotNil(result.results.artists)
        XCTAssertEqual(result.results.artists?.data.count, 1)
        XCTAssertEqual(result.results.artists?.data[0].attributes?.name, "Test Artist")
        XCTAssertEqual(result.results.artists?.data[0].attributes?.genreNames, ["Pop", "Rock"])
    }
    
    func testSearchByTitle() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(developerToken: mockToken, storefront: mockStorefront, session: session)
        
        // Set up the mock response
        let mockResponseData = """
        {
            "results": {
                "songs": {
                    "data": [
                        {
                            "id": "987654321",
                            "type": "songs",
                            "href": "/v1/catalog/us/songs/987654321",
                            "attributes": {
                                "name": "Test Song",
                                "artistName": "Test Artist",
                                "albumName": "Test Album",
                                "durationInMillis": 240000,
                                "genreNames": ["Pop"],
                                "url": "https://music.apple.com/us/song/test-song/987654321"
                            }
                        }
                    ],
                    "href": "/v1/catalog/us/search?term=test&types=songs",
                    "next": null
                }
            }
        }
        """.data(using: .utf8)!
        
        session.mockResponse = (mockResponseData, HTTPURLResponse(url: URL(string: "https://api.music.apple.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        // Perform the search
        let result = try await client.searchByTitle("Test Song")
        
        // Verify the results
        XCTAssertNotNil(result.results.songs)
        XCTAssertEqual(result.results.songs?.data.count, 1)
        XCTAssertEqual(result.results.songs?.data[0].attributes?.name, "Test Song")
        XCTAssertEqual(result.results.songs?.data[0].attributes?.artistName, "Test Artist")
        XCTAssertEqual(result.results.songs?.data[0].attributes?.albumName, "Test Album")
    }
    
    func testSearchByArtistAndTitle() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(developerToken: mockToken, storefront: mockStorefront, session: session)
        
        // Set up the mock response
        let mockResponseData = """
        {
            "results": {
                "songs": {
                    "data": [
                        {
                            "id": "987654321",
                            "type": "songs",
                            "href": "/v1/catalog/us/songs/987654321",
                            "attributes": {
                                "name": "Test Song",
                                "artistName": "Test Artist",
                                "albumName": "Test Album",
                                "durationInMillis": 240000,
                                "genreNames": ["Pop"],
                                "url": "https://music.apple.com/us/song/test-song/987654321"
                            }
                        }
                    ],
                    "href": "/v1/catalog/us/search?term=test&types=songs,artists",
                    "next": null
                },
                "artists": {
                    "data": [
                        {
                            "id": "123456789",
                            "type": "artists",
                            "href": "/v1/catalog/us/artists/123456789",
                            "attributes": {
                                "name": "Test Artist",
                                "genreNames": ["Pop", "Rock"],
                                "url": "https://music.apple.com/us/artist/test-artist/123456789"
                            }
                        }
                    ],
                    "href": "/v1/catalog/us/search?term=test&types=songs,artists",
                    "next": null
                }
            }
        }
        """.data(using: .utf8)!
        
        session.mockResponse = (mockResponseData, HTTPURLResponse(url: URL(string: "https://api.music.apple.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        // Perform the search
        let result = try await client.searchByArtistAndTitle(artist: "Test Artist", title: "Test Song")
        
        // Verify the results
        XCTAssertNotNil(result.results.songs)
        XCTAssertEqual(result.results.songs?.data.count, 1)
        XCTAssertEqual(result.results.songs?.data[0].attributes?.name, "Test Song")
        
        XCTAssertNotNil(result.results.artists)
        XCTAssertEqual(result.results.artists?.data.count, 1)
        XCTAssertEqual(result.results.artists?.data[0].attributes?.name, "Test Artist")
    }
    
    func testGetSongDetails() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(developerToken: mockToken, storefront: mockStorefront, session: session)
        
        // Set up the mock response
        let mockResponseData = """
        {
            "data": [
                {
                    "id": "987654321",
                    "type": "songs",
                    "href": "/v1/catalog/us/songs/987654321",
                    "attributes": {
                        "name": "Test Song",
                        "artistName": "Test Artist",
                        "albumName": "Test Album",
                        "durationInMillis": 240000,
                        "genreNames": ["Pop"],
                        "isrc": "USABC1234567",
                        "releaseDate": "2023-01-01",
                        "url": "https://music.apple.com/us/song/test-song/987654321",
                        "previews": [
                            {
                                "url": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview123/v4/12/34/56/12345678-1234-1234-1234-123456789012/mzaf_1234567890123456789.plus.aac.p.m4a"
                            }
                        ]
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        session.mockResponse = (mockResponseData, HTTPURLResponse(url: URL(string: "https://api.music.apple.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        // Get song details
        let song = try await client.getSongDetails(id: "987654321")
        
        // Verify the results
        XCTAssertEqual(song.id, "987654321")
        XCTAssertEqual(song.attributes?.name, "Test Song")
        XCTAssertEqual(song.attributes?.artistName, "Test Artist")
        XCTAssertEqual(song.attributes?.albumName, "Test Album")
        XCTAssertEqual(song.attributes?.isrc, "USABC1234567")
        XCTAssertEqual(song.attributes?.releaseDate, "2023-01-01")
    }
}
