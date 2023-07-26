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
            Text("A SwiftUI MacOS project to show users their top spotify data, playlists and provide some recommendations. This uses the spotify web api. It is currently using the \"authorization code flow\" and not the \"authorization code with PKCE\", thus requires both a client id and client secret from the spotify developer dashboard.")
                .fontWeight(.medium)
                .padding(.leading)
                .padding(.trailing)
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
