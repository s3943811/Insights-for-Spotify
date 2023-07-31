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
    
    
    var cancellables: Set<AnyCancellable> = []
    
    let api = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: ProcessInfo.processInfo.environment["CLIENT_ID"]!
        )
    )
    
    let codeVerifier: String
    let codeChallenge: String
    let state: String
    
    let key = "Insights-auth"
    
    init() {
        self.codeVerifier = String.randomURLSafe(length: 128)
        self.codeChallenge = String.makeCodeChallenge(codeVerifier: self.codeVerifier)
        self.state = String.randomURLSafe(length: 128)
        
        self.api.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authManagerDidChange)
            .store(in: &cancellables)
        self.api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authManagerDidDeauthorise)
            .store(in: &cancellables)
        load()
    }
    
    func generateAuthURL() -> URL {
        let authorizationURL = api.authorizationManager.makeAuthorizationURL(
            redirectURI: redirectURL!,
            codeChallenge: codeChallenge,
            state: state,
            scopes: [
                .playlistModifyPrivate,
                .playlistModifyPublic,
                .userTopRead
            ]
        )!
        return authorizationURL
    }
    func save() {
        do {
            let authManagerData = try JSONEncoder().encode(self.api.authorizationManager)
            UserDefaults.standard.set(authManagerData, forKey: self.key)
        } catch {
            print("could not encode data")
        }
    }
    func authManagerDidChange() {
        if self.api.authorizationManager.isAuthorized() {
            self.authenticationState = .authenticated
        }
        else {
            self.authenticationState = .none
        }
        save()
    }
    func authManagerDidDeauthorise() {
        self.authenticationState = .none
        UserDefaults.standard.removeObject(forKey: self.key)
    }
    func load() {
        if let savedData = UserDefaults.standard.object(forKey: self.key) as? Data {
            do {
                let authManager = try JSONDecoder().decode(AuthorizationCodeFlowPKCEManager.self, from: savedData)
                self.api.authorizationManager = authManager
            } catch {
                print("could not decode")
            }
        }
    }
    
}
