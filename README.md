# AppleMusicKit & SonosKit

This project contains two Swift 6 libraries:
1. **AppleMusicKit**: A library for interacting with the Apple Music API, with a focus on search functionality.
2. **SonosKit**: A library for controlling Sonos speakers through the node-sonos-http-api.

## Features

### AppleMusicKit
- Search the Apple Music catalog by artist name
- Search the Apple Music catalog by song title
- Search by both artist and title
- Get detailed information about specific songs
- Generate Apple Music API developer tokens using ES256 algorithm
- Command-line interface for testing the library

### SonosKit
- Control playback (play, pause, stop, next, previous)
- Manage queue (add tracks, clear queue)
- Set volume
- Get player state
- List available rooms/zones
- Play Apple Music songs, albums, and playlists
- Command-line interface for testing the library

## Requirements

### AppleMusicKit
- Swift 6.0+
- macOS 14.0+ or iOS 17.0+
- Apple Music API developer token

### SonosKit
- Swift 6.0+
- macOS 14.0+
- [node-sonos-http-api](https://github.com/jishi/node-sonos-http-api) running locally or on a network

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/AppleMusicKit.git", from: "1.0.0")
]
```

## Usage

### AppleMusicKit Library Usage

```swift
import AppleMusicKit

// Initialize with an existing developer token
let client = AppleMusicClient(developerToken: "your_developer_token", storefront: "us")

// Or initialize with a Secret (private key, team ID, key ID)
let secret = Secret(privateKey: privateKeyString, teamId: "YOUR_TEAM_ID", keyId: "YOUR_KEY_ID")
let client = try await AppleMusicClient(secret: secret, storefront: "us")

// Search by artist
let artistResults = try await client.searchByArtist("Queen")

// Search by song title
let songResults = try await client.searchByTitle("Bohemian Rhapsody")

// Search by both artist and title
let combinedResults = try await client.searchByArtistAndTitle(artist: "Queen", title: "Bohemian Rhapsody")

// Get details for a specific song
let songDetails = try await client.getSongDetails(id: "1234567890")

// Generate a token directly
let tokenFactory = AppleMusicTokenFactory(secret: secret)
let token = try await tokenFactory.generateToken()
```

### SonosKit Library Usage

```swift
import SonosKit

// Initialize with default host and port
let client = SonosClient()

// Or initialize with custom host, port, and default room
let client = SonosClient(host: "192.168.1.100", port: 5005, defaultRoom: "Living Room")

// Control playback
try await client.play()
try await client.pause()
try await client.stop()
try await client.next()
try await client.previous()

// Set volume
try await client.setVolume(50)

// Manage queue
try await client.addToQueue(uri: "spotify:track:5hTpBe8h35rJ67eAWHQsJx")
try await client.clearQueue()

// Play Apple Music content
try await client.playAppleMusic(contentType: .song, contentId: "355364259", mode: .queue)
try await client.playAppleMusic(contentType: .album, contentId: "355363490", mode: .now)
try await client.playAppleMusic(contentType: .playlist, contentId: "pl.ed52c9eeaa0740079c21fa8e455b225e", mode: .next)

// Get state
let state = try await client.getState()
print("Now playing: \(state.currentTrack.title) by \(state.currentTrack.artist)")

// List rooms
let rooms = try await client.getRooms()
for room in rooms {
    print(room)
}
```

### AppleMusicCLI Usage

```bash
# Search by artist (uses built-in token generation)
swift run AppleMusicCLI artist "Queen"

# Search by title (uses built-in token generation)
swift run AppleMusicCLI title "Bohemian Rhapsody"

# Search by both artist and title (uses built-in token generation)
swift run AppleMusicCLI search "Queen" "Bohemian Rhapsody"

# Get song details (uses built-in token generation)
swift run AppleMusicCLI song "1234567890"

# Generate a token using the built-in ES256 implementation (default)
swift run AppleMusicCLI token

# Generate a token using a script
swift run AppleMusicCLI token -p "/path/to/generate_jwt.js"

# Generate a token with custom credentials
swift run AppleMusicCLI token --team-id "YOUR_TEAM_ID" --key-id "YOUR_KEY_ID" --key-path "/path/to/private_key.p8"
```

### SonosCLI Usage

First, start the node-sonos-http-api server:

```bash
# Start the Sonos HTTP API server
./setup_sonos_api.sh
```

Then, in a new terminal window:

```bash
# Get the current state (default command)
swift run SonosCLI

# Play music
swift run SonosCLI play --room "Living Room"

# Pause music
swift run SonosCLI pause --room "Living Room"

# Stop music
swift run SonosCLI stop --room "Living Room"

# Skip to next track
swift run SonosCLI next --room "Living Room"

# Skip to previous track
swift run SonosCLI previous --room "Living Room"

# Set volume
swift run SonosCLI volume 50 --room "Living Room"

# Add a track to the queue
swift run SonosCLI queue add "spotify:track:5hTpBe8h35rJ67eAWHQsJx" --room "Living Room"

# Clear the queue
swift run SonosCLI queue clear --room "Living Room"

# Play Apple Music song now
swift run SonosCLI applemusic song "355364259" --mode now --room "Living Room"

# Add Apple Music album to queue
swift run SonosCLI applemusic album "355363490" --room "Living Room"

# Add Apple Music playlist to be played next
swift run SonosCLI applemusic playlist "pl.ed52c9eeaa0740079c21fa8e455b225e" --mode next --room "Living Room"

# List available rooms
swift run SonosCLI rooms
```

## Finding Apple Music IDs

You can find Apple Music song, album, and playlist IDs in several ways:

1. **Using iTunes/Music App**: Right-click on a song, album, or playlist and select "Share" -> "Copy Link". The ID is in the URL:
   - Song: `https://itunes.apple.com/{country}/album/{songName}/{albumID}?i={songID}`
   - Album: `https://itunes.apple.com/{country}/album/{albumName}/{albumID}`
   - Playlist: `https://music.apple.com/{country}/playlist/{playlistName}/{playlistID}`

2. **Using iTunes Search API**: You can search for content using the iTunes Search API and extract the IDs from the results.

## Token Generation

The AppleMusicKit library supports multiple ways to generate Apple Music API developer tokens:

1. Using an existing token
2. Using the built-in ES256 implementation with JWTKit (recommended)
3. Using external scripts (for special cases):
   - Bash scripts (like the provided `generate_jws.sh`)
   - Node.js scripts (like the provided `generate_jwt.js`)

## License

MIT
