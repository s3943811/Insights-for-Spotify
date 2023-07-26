//
//  ContentView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 25/7/2023.
//

import Combine
import SwiftUI
import SpotifyWebAPI

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @State var cancellables: [AnyCancellable] = []
    @ObservedObject var spotify = envSpotify()
    
    enum AuthenticationState  {
        case none, working, authenticated, error
    }
    
    @State private var isAuthenticated = AuthenticationState.none
    
    @State var logTxt = "Login"
    @State var logImage = "person.crop.circle.badge.checkmark"
    
    func handleURL(_ url: URL) {
        guard url.scheme == spotify.redirectURL?.scheme else {
            print("error")
            return
        }
        print(url)
        spotify.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            codeVerifier: spotify.codeVerifier,
            state: spotify.state)
        .sink(receiveCompletion: { completion in
            switch completion {
                case .finished:
                    print("successfully authorized")
                    isAuthenticated = .authenticated
                case .failure(let error):
                    if let authError = error as? SpotifyAuthorizationError, authError.accessWasDenied {
                        print("The user denied the authorization request")
                        isAuthenticated = .error
                    }
                    else {
                        print("couldn't authorize application: \(error)")
                    }
            }
        })
        .store(in: &cancellables)
    }
    
    var body: some View {
        ZStack {
            LoginView()
                .opacity(spotify.authenticationState != .authenticated ? 1 : 0)
                .animation(.easeInOut, value: spotify.authenticationState)

            Label(logTxt, systemImage: logImage)
                .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                .onHover { hover in
                    withAnimation {
                        if hover {
                            logTxt = "Logout"
                            logImage = "person.crop.circle.badge.minus"
                        }
                        else {
                            logTxt = "Login"
                            logImage = "person.crop.circle.badge.checkmark"
                        }
                    }
                }
        }
        .onOpenURL(perform: handleURL(_:))
        .environmentObject(spotify)
        .onChange(of: isAuthenticated) { state in
            print(state)
            if state == .authenticated {
                spotify.authenticationState = .authenticated
            }
            else {
                spotify.authenticationState = .error
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
