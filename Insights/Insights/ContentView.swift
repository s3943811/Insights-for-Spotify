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
    @EnvironmentObject var spotify: envSpotify
    @State var viewState = ViewState.login
    @State private var isAuthenticated = AuthenticationState.none
    @State var trackAndArtist: TrackAndArtist = TrackAndArtist(tracks: [.time], artists: [.crumb])
    @State var currentUser: SpotifyUser = .sampleCurrentUserProfile
    @State var dataState: DataChoice = .artist
    @State var searchState: SearchState = .none
    
    let menus = [MenuItem(id: .home, name: "Home", image: "music.note.house.fill"), MenuItem(id: .top, name: "Top", image: "trophy.fill"), MenuItem(id: .recommendations, name: "Recommendations", image: "wave.3.forward.circle.fill")]
    enum AuthenticationState  {
        case none, working, authenticated, error
    }

    var body: some View {
        NavigationSplitView() {
            if viewState != .login {
                List(menus, selection: $viewState) { item in
                    Label(item.name, systemImage: item.image)
                }
            }
            
        } detail: {
            ZStack {
                LoginView()
                    .opacity(spotify.authenticationState != .authenticated ? 1 : 0)
                    .animation(.easeInOut, value: spotify.authenticationState)
                switch searchState {
                case .error, .none:
                    Text("Sorry, an error has occured - please check your internet connection then try again")
                        .frame(maxHeight: .infinity)
                        .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                    Button("Try again") {
                        getCurrentUser()
                        getTop5()
                    }
                    .offset(y:40)
                    .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                case .searching:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                        .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                case .success:
                    if viewState == .top {
                        UserTopView(viewState: $viewState, dataState: $dataState)
                            .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                    } else if viewState == .recommendations {
                        RecommendationsView(currentUser: $currentUser, trackAndArtist: $trackAndArtist)
                            .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                    } else if viewState == .home {
                        HomeView(currentUser: $currentUser, trackAndArtist: $trackAndArtist, viewState: $viewState, dataState: $dataState)
                            .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Logout") {
                    logout()
                }
                .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                .animation(.default, value: spotify.authenticationState)
            }
        }
        .onAppear {
            if spotify.api.authorizationManager.isAuthorized() {
                isAuthenticated = .authenticated
            }
        }
        .onOpenURL(perform: handleURL(_:))
//        .onChange(of: viewState) { new in
//            print(viewState)
//        }
        
        .onChange(of: isAuthenticated) { state in
            print(state)
            if state == .authenticated {
                spotify.authenticationState = .authenticated
//                setUserDetails()
                getCurrentUser()
                getTop5()
                viewState = .home
            }
        }
    }
    
    func logout() {
        spotify.api.authorizationManager.deauthorize()
        isAuthenticated = .none
        viewState = .login
    }
    
    func handleURL(_ url: URL) {
        guard url.scheme == spotify.redirectURL?.scheme else {
            print("error")
            return
        }
        print(url)
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
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
        .store(in: &spotify.cancellables)
    }
    
    func getCurrentUser() {
        searchState = .searching
        spotify.api.currentUserProfile()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        searchState = .success
                    case .failure(let error):
                        print(error)
                        searchState = .error
                    }
                    print(completion)
                },
                receiveValue: { results in
                    currentUser = results
                }
            )
            .store(in: &spotify.cancellables)
    }
    
    func getTop5() {
        searchState = .searching
        spotify.api.currentUserTopArtists(.mediumTerm, offset: 0, limit: 5)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        searchState = .success
                    case .failure(let error):
                        print(error)
                        searchState = .error
                    }
                },
                receiveValue: { results in
                    trackAndArtist.artists = results.items
                }
            )
            .store(in: &spotify.cancellables)
        searchState = .searching
        spotify.api.currentUserTopTracks(.mediumTerm, offset: 0, limit: 5)
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            searchState = .success
                        case .failure(let error):
                            print(error)
                            searchState = .error
                        }
                    },
                    receiveValue: { results in
                        trackAndArtist.tracks = results.items
                    }
                )
                .store(in: &spotify.cancellables)
    }
}

struct MenuItem: Identifiable, Hashable {
    var id: ViewState
    var name: String
    var image: String
}

struct ContentView_Previews: PreviewProvider {
    static let exampleUser: SpotifyUser = .sampleCurrentUserProfile
    static var previews: some View {
        ContentView(currentUser: exampleUser)
    }
}
