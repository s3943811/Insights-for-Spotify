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
    
    @State var logTxt = "Login"
    @State var logImage = "person.crop.circle.badge.checkmark"
    
    let menus = [MenuItem(id: .top, name: "Top", image: "trophy.fill"), MenuItem(id: .recommendations, name: "Recommendations", image: "wave.3.forward.circle.fill")]
    

    @State var viewState = ViewState.login
    
    enum AuthenticationState  {
        case none, working, authenticated, error
    }
    
    @State private var isAuthenticated = AuthenticationState.none
    
    @State var userDetail = User(id: "")

    
    var body: some View {
        NavigationSplitView() {
            List(menus, selection: $viewState) { item in
                Label(item.name, systemImage: item.image)
            }
            
        } detail: {
            ZStack {
                LoginView()
                    .opacity(spotify.authenticationState != .authenticated ? 1 : 0)
                    .animation(.easeInOut, value: spotify.authenticationState)
                if viewState == .top {
                    UserTopView(viewState: $viewState)
                        .opacity(spotify.authenticationState == .authenticated ? 1 : 0)
                } else if viewState == .recommendations {
                    
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
                setUserDetails()
                viewState = .top
            }
            else {
                spotify.authenticationState = .error
            }
        }
    }
    
    func setUserDetails() {
        spotify.api.currentUserProfile()
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { results in
                    userDetail.displayName = results.displayName
                    userDetail.id = results.id
                }
            )
            .store(in: &spotify.cancellables)
    }
    
    func logout() {
        spotify.api.authorizationManager.deauthorize()
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
}

struct User {
    var id: String
    var displayName: String?
    var name: String {
        self.displayName == nil ? self.id : self.displayName!
    }
}

struct MenuItem: Identifiable, Hashable {
    var id: ViewState
    var name: String
    var image: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
