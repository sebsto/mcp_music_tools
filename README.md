# Music Agent

A Swift 6 project containing three libraries for controlling your music ecosystem:

1. **AppleMusicKit**: A library for interacting with the Apple Music API
2. **SonosKit**: A library for controlling Sonos speakers through the node-sonos-http-api
3. **AmplifierKit**: A library for controlling Denon/Marantz amplifiers

## Features

### AppleMusicKit
- Search the Apple Music catalog by artist name, song title, or both
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

### AmplifierKit
- Power on/off your amplifier
- Switch between input sources
- Get available source names
- Get amplifier status
- SSL certificate bypass for local network devices
- Command-line interface for testing the library

## Requirements

- Swift 6.0+
- macOS 14.0+ or iOS 17.0+
- For AppleMusicKit: Apple Music API developer token
- For SonosKit: [node-sonos-http-api](https://github.com/jishi/node-sonos-http-api) running locally or on a network
- For AmplifierKit: Denon/Marantz amplifier on your local network

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/music_agent.git", from: "1.0.0")
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

### AmplifierKit Library Usage

```swift
import AmplifierKit

// Initialize with default host and port
let config = AmplifierConfig(host: "192.168.1.37", port: 10443)
let controller = HTTPAmplifierController(config: config)

// Power control
try await controller.powerOn()
try await controller.powerOff()

// Source control
try await controller.switchToSource(index: 4)  // Switch to source with index 4
try await controller.switchToSonos()           // Shortcut to switch to Sonos
try await controller.switchToAppleTV()         // Shortcut to switch to Apple TV

// Get information
let sources = try await controller.getSourceNames()
let status = try await controller.getMainZoneStatus()
print("Zone: \(status.name), Power: \(status.isPowered ? "On" : "Off")")
```

## Command-Line Interfaces

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

# Set volume
swift run SonosCLI volume 50 --room "Living Room"

# Play Apple Music song now
swift run SonosCLI applemusic song "355364259" --mode now --room "Living Room"

# List available rooms
swift run SonosCLI rooms
```

### AmplifierCLI Usage

```bash
# Power on the amplifier
swift run AmplifierCLI power-on

# Power off the amplifier
swift run AmplifierCLI power-off

# Switch to Sonos input
swift run AmplifierCLI sonos

# Switch to Apple TV input
swift run AmplifierCLI appletv

# Switch to a specific source by index
swift run AmplifierCLI source 3

# List all available sources with their indices
swift run AmplifierCLI sources

# Get amplifier status
swift run AmplifierCLI status
```

## Setting Up Apple Music API Access

To use the Apple Music API, you need to obtain developer credentials:

1. **Enroll in the Apple Developer Program**: If you haven't already, enroll at [developer.apple.com](https://developer.apple.com/).

2. **Create a MusicKit identifier**:
   - Go to [Apple Developer Account](https://developer.apple.com/account/)
   - Navigate to "Certificates, Identifiers & Profiles"
   - Select "Identifiers" and click the "+" button
   - Choose "Media IDs" and follow the instructions to register a MusicKit identifier

3. **Generate a private key**:
   - In your Apple Developer Account, go to "Keys"
   - Click the "+" button to add a new key
   - Give it a name and select "MusicKit" checkbox
   - Click "Continue" and then "Register"
   - **IMPORTANT**: Download the private key file (.p8) when prompted. Apple only provides this file ONCE.

4. **Note your credentials**:
   - **Team ID**: Found in the top-right corner of your Apple Developer Account page
   - **Key ID**: The identifier for the key you just created
   - **Private Key**: The contents of the .p8 file you downloaded

5. **Update the Secret.swift file**:
   - Open `Sources/AppleMusicKit/Secret.swift`
   - Uncomment the `defaultSecret` section
   - Replace the placeholder values with your actual credentials:

```swift
public let defaultSecret = Secret(
  privateKey: """
    -----BEGIN PRIVATE KEY-----
    YOUR_PRIVATE_KEY_CONTENT_HERE
    -----END PRIVATE KEY-----
    """,
  teamId: "YOUR_TEAM_ID",
  keyId: "YOUR_KEY_ID"
)
```

For more information, see [Apple's documentation on generating developer tokens](https://developer.apple.com/documentation/applemusicapi/generating-developer-tokens).

## Setting Up Sonos Control

1. Install and run the [node-sonos-http-api](https://github.com/jishi/node-sonos-http-api):
   ```bash
   git clone https://github.com/jishi/node-sonos-http-api.git
   cd node-sonos-http-api
   npm install
   npm start
   ```

2. The API will automatically discover your Sonos speakers on the network.

3. Update the SonosClient configuration with the host and port where the API is running:
   ```swift
   let client = SonosClient(host: "192.168.1.100", port: 5005)
   ```

## Setting Up Amplifier Control

1. Ensure your Denon/Marantz amplifier is connected to your local network.

2. Find the IP address of your amplifier (check your router's DHCP client list or the amplifier's network settings).

3. Update the AmplifierConfig with the correct IP address:
   ```swift
   let config = AmplifierConfig(host: "192.168.1.37", port: 10443)
   ```

4. The AmplifierKit includes SSL certificate bypass functionality for dealing with self-signed certificates commonly used by these devices.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
