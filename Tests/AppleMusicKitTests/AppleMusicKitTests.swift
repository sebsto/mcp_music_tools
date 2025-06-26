import Foundation
import Testing

@testable import AppleMusicKit

// Mock implementation of URLSessionProtocol for testing
class MockURLSession: URLSessionProtocol {
    var mockResponse: (Data, URLResponse) = (Data(), URLResponse())

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        mockResponse
    }
}

@Suite("AppleMusicKit Tests")
struct AppleMusicKitTests {
    // Mock developer token for testing
    let mockToken = "mock_developer_token"
    let mockStorefront = "us"

    @Test("Search by artist should return correct results")
    func testSearchByArtist() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(
            developerToken: mockToken,
            storefront: mockStorefront,
            session: session
        )

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

        session.mockResponse = (
            mockResponseData,
            HTTPURLResponse(
                url: URL(string: "https://api.music.apple.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )

        // Perform the search
        let result = try await client.searchByArtist("Test Artist")

        // Verify the results
        let artists = try #require(result.results.artists, "Artists should not be nil")
        #expect(artists.data.count == 1)
        #expect(artists.data[0].attributes?.name == "Test Artist")
        #expect(artists.data[0].attributes?.genreNames == ["Pop", "Rock"])
    }

    @Test("Search by title should return correct results")
    func testSearchByTitle() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(
            developerToken: mockToken,
            storefront: mockStorefront,
            session: session
        )

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

        session.mockResponse = (
            mockResponseData,
            HTTPURLResponse(
                url: URL(string: "https://api.music.apple.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )

        // Perform the search
        let result = try await client.searchByTitle("Test Song")

        // Verify the results
        let songs = try #require(result.results.songs, "Songs should not be nil")
        #expect(songs.data.count == 1)
        #expect(songs.data[0].attributes?.name == "Test Song")
        #expect(songs.data[0].attributes?.artistName == "Test Artist")
        #expect(songs.data[0].attributes?.albumName == "Test Album")
    }

    @Test("Search by artist and title should return correct results")
    func testSearchByArtistAndTitle() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(
            developerToken: mockToken,
            storefront: mockStorefront,
            session: session
        )

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

        session.mockResponse = (
            mockResponseData,
            HTTPURLResponse(
                url: URL(string: "https://api.music.apple.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )

        // Perform the search
        let result = try await client.searchByArtistAndTitle(artist: "Test Artist", title: "Test Song")

        // Verify the results
        let songs = try #require(result.results.songs, "Songs should not be nil")
        #expect(songs.data.count == 1)
        #expect(songs.data[0].attributes?.name == "Test Song")

        let artists = try #require(result.results.artists, "Artists should not be nil")
        #expect(artists.data.count == 1)
        #expect(artists.data[0].attributes?.name == "Test Artist")
    }

    @Test("Get song details should return correct information")
    func testGetSongDetails() async throws {
        // Create a mock URL session for testing
        let session = MockURLSession()
        let client = AppleMusicClient(
            developerToken: mockToken,
            storefront: mockStorefront,
            session: session
        )

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

        session.mockResponse = (
            mockResponseData,
            HTTPURLResponse(
                url: URL(string: "https://api.music.apple.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )

        // Get song details
        let song = try await client.getSongDetails(id: "987654321")

        // Verify the results
        #expect(song.id == "987654321")
        #expect(song.attributes?.name == "Test Song")
        #expect(song.attributes?.artistName == "Test Artist")
        #expect(song.attributes?.albumName == "Test Album")
        #expect(song.attributes?.isrc == "USABC1234567")
        #expect(song.attributes?.releaseDate == "2023-01-01")
    }
}
