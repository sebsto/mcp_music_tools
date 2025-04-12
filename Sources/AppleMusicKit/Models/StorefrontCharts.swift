import Foundation

// MARK: - Storefront Charts Response Models

/// Response structure for storefront charts playlists
public struct StorefrontChartsResponse: Codable {
    public let data: [Playlist]
    public let meta: ChartsMeta?
    public let next: String?
    
    public init(data: [Playlist], meta: ChartsMeta? = nil, next: String? = nil) {
        self.data = data
        self.meta = meta
        self.next = next
    }
}

/// Meta information for charts
public struct ChartsMeta: Codable {
    public let results: ChartResults?
    
    public init(results: ChartResults? = nil) {
        self.results = results
    }
}

/// Chart results information
public struct ChartResults: Codable {
    public let order: [String]?
    public let rawOrder: [String]?
    
    public init(order: [String]? = nil, rawOrder: [String]? = nil) {
        self.order = order
        self.rawOrder = rawOrder
    }
    
    enum CodingKeys: String, CodingKey {
        case order
        case rawOrder = "raw-order"
    }
}

// MARK: - Chart Types

/// Types of charts available in Apple Music
public enum ChartType: String {
    case mostPlayed = "most-played"
    case dailyGlobal = "daily-global"
    case dailyCountry = "daily-country"
    case cityCharts = "city-charts"
    case topAlbums = "top-albums"
    case topSongs = "top-songs"
    case topPlaylists = "top-playlists"
    case trending = "trending"
    
    public var displayName: String {
        switch self {
        case .mostPlayed:
            return "Most Played"
        case .dailyGlobal:
            return "Daily Global"
        case .dailyCountry:
            return "Daily Country"
        case .cityCharts:
            return "City Charts"
        case .topAlbums:
            return "Top Albums"
        case .topSongs:
            return "Top Songs"
        case .topPlaylists:
            return "Top Playlists"
        case .trending:
            return "Trending"
        }
    }
}

/// Chart genre types
public enum ChartGenre: String {
    case all
    case alternative
    case classical
    case country
    case electronic
    case hipHopRap = "hip-hop-rap"
    case jazz
    case kpop
    case latin
    case pop
    case rbSoul = "r-b-soul"
    case rock
    
    public var displayName: String {
        switch self {
        case .all:
            return "All Genres"
        case .alternative:
            return "Alternative"
        case .classical:
            return "Classical"
        case .country:
            return "Country"
        case .electronic:
            return "Electronic"
        case .hipHopRap:
            return "Hip-Hop/Rap"
        case .jazz:
            return "Jazz"
        case .kpop:
            return "K-Pop"
        case .latin:
            return "Latin"
        case .pop:
            return "Pop"
        case .rbSoul:
            return "R&B/Soul"
        case .rock:
            return "Rock"
        }
    }
}
