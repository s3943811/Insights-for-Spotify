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
