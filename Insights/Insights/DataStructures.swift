//
//  DataChoice.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 27/7/2023.
//

import Foundation
import SpotifyWebAPI

enum DataChoice {
    case artist, songs
}

enum ViewState {
    case login, top, recommendations, home
}

struct TrackAndArtist {
    var tracks: [Track]
    var artists: [Artist]
}

enum SearchState {
    case none, searching, success, error
}

struct CardItem {
    var track: Track? = nil
    var artist: Artist? = nil
    var playlist: Playlist<PlaylistItemsReference>? = nil
    
    enum TypeOfItem {
        case track, playlist, artist, none
    }
    
    var typeofItem: TypeOfItem {
        if let _ = track {
            return .track
        }
        if let _ = artist {
            return .artist
        }
        if let _ = playlist {
            return .playlist
        }
        return .none
    }
    
    var imageURL: URL? {
        if let song = track {
            return song.album?.images?[1].url
        }
        if let artist = artist {
            return artist.images?[1].url
        }
        if let playlist = playlist {
            if playlist.images.isEmpty {
                return nil
            } else {
                return playlist.images[0].url
            }
        }
        return nil
    }
    
    var name: String {
        if let song = track {
            return song.name
        }
        if let artist = artist {
            return artist.name
        }
        if let playlist = playlist {
            return playlist.name
        }
        return ""
    }
    
    var artists: [Artist]? {
        if let song = track {
            return song.artists
        }
        return nil
    }
    
    var owner: SpotifyUser? {
        if let playlist = playlist {
            return playlist.owner
        }
        return nil
    }
    
    var externalURL: URL? {
        if let song = track {
            return song.externalURLs?["spotify"]
        }
        if let artist = artist {
            return artist.externalURLs?["spotify"]
        }
        if let playlist = playlist {
            return playlist.externalURLs?["spotify"]
        }
        return URL(string: "")
    }
    
    var systemImage: String {
        if let _ = artist {
            return "music.mic"
        }
        else {
            return "music.quarternote.3"
        }
    }
    
}
