//
//  LoginView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 25/7/2023.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var spotify: envSpotify
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            Text("Insights for Spotify")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Text("A SwiftUI MacOS project to show users their top spotify data, playlists and provide some recommendations. If you choose to accept the permissions and ensure you reopen the link in the app. Afterwards you may close the window in your browser asking for permissions.")
                .fontWeight(.medium)
                .padding([.leading, .trailing, .bottom])
                .multilineTextAlignment(.center)
            
            Text("This uses the spotify web api, and the Authorization Code with PKCE Flow so the client secret does not have to be stored.")
                .fontWeight(.thin)
                .padding([.leading, .trailing, .bottom])
                .multilineTextAlignment(.center)
            
            Text("Developed by Maximus Dionyssopoulos")
                .font(.body)
                .fontWeight(.thin)
                .padding(3)
            Button {
                spotify.authenticationState = .working
                openURL(spotify.generateAuthURL())
            
            } label: {
                Label("Login to Spotify", systemImage: "person.badge.plus")
                    .padding(2)
                    .font(.callout.weight(.regular))
            }
            .disabled(spotify.authenticationState == .working ? true : false)
            .buttonStyle(.plain)
            .foregroundColor(.white)
            .padding(5)
            .background(.green)
            .clipShape(Capsule())
            .padding(.top)
        }
        .frame(minWidth: 500, minHeight: 500)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
