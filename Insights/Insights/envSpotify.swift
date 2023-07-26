//
//  SpotifyAPI.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 25/7/2023.
//

import Foundation
import Combine
import SpotifyWebAPI

class envSpotify: ObservableObject {
    let redirectURL = URL(string: "insights://login-callback")
    
    let spotify = SpotifyAPI(authorizationManager:
                                AuthorizationCodeFlowManager(
                                    clientId: ProcessInfo.processInfo.environment["CLIENT_ID"]!,
                                    clientSecret: ProcessInfo.processInfo.environment["CLIENT_SECRET"]!))
    enum AuthenticationState  {
        case none, working, authenticated, error
    }
    @Published var authenticationState = AuthenticationState.none
    
    func generateAuthURL() -> URL {
        let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: redirectURL!,
            showDialog: true,
            scopes: [
                .playlistModifyPrivate,
                .playlistModifyPublic
            ]
        )!
        return authorizationURL
    }
    
}
