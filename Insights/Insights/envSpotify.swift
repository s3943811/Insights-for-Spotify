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
    
    enum AuthenticationState  {
        case none, working, authenticated, error
    }
    @Published var authenticationState = AuthenticationState.none
    
    let spotify = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: ProcessInfo.processInfo.environment["CLIENT_ID"]!
        )
    )
    let codeVerifier: String
    let codeChallenge: String
    let state: String
    
    init() {
        self.codeVerifier = String.randomURLSafe(length: 128)
        self.codeChallenge = String.makeCodeChallenge(codeVerifier: self.codeVerifier)
        self.state = String.randomURLSafe(length: 128)
    }
    
    func generateAuthURL() -> URL {
        let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: redirectURL!,
            codeChallenge: codeChallenge,
            state: state,
            scopes: [
                .playlistModifyPrivate,
                .playlistModifyPublic
            ]
        )!
        return authorizationURL
    }
    
}
