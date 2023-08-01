//
//  HomeView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 31/7/2023.
//

import SwiftUI
import SpotifyWebAPI

struct HomeView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var spotify: envSpotify
    @Binding var currentUser: SpotifyUser
    @Binding var trackAndArtist: TrackAndArtist
    @Binding var viewState: ViewState
    @Binding var dataState: DataChoice
    @State var playlists = [Playlist<PlaylistItemsReference>]()
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 130)),
    ]
    func getPlaylist() {
        spotify.api.currentUserPlaylists(limit: 20)
            .sink(
                receiveCompletion: { completion in
                    print(completion, "2")
                },
                receiveValue: { results in
                    playlists.append(contentsOf: results.items)
                }
            )
            .store(in: &spotify.cancellables)
    }
    
    var body: some View {
        let userName = currentUser.displayName ?? currentUser.id
        ScrollView {
            HStack {
                if currentUser.images!.isEmpty {
                    Image(systemName: "person.circle.fill")
                        .symbolVariant(.circle)
                        .font(.largeTitle)
                        .frame(width: 48, height: 48)
                } else {
                    let image = currentUser.images![1].url
                    AsyncImage(url: image) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        case .failure(_):
                            Image(systemName: "person.circle.fill")
                                .symbolVariant(.circle)
                                .font(.largeTitle)
                        default:
                            ProgressView()
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                }
                Text("Hello, \(userName)")
                    .font(.title)
                Spacer()
            }
            .onTapGesture {
                if let url = currentUser.externalURLs?["spotify"] {
                    openURL(url)
                }
            }
            HStack {
                Text("Your Playlists:")
                    .padding()
                    .font(.title)
                Spacer()
            }
            LazyVGrid(columns: gridItems) {
                ForEach(playlists, id: \.self) { playlist in
                    PlaylistView(playlist: playlist)
                }
            }
            HStack {
                Text("Your Top 5 Songs for the last 6 months:")
                    .padding()
                    .font(.title)
                Spacer()
                Button("View More") {
                    dataState = .songs
                    viewState = .top
                }
                .buttonStyle(.borderless)
                .padding(5)
                .padding(.trailing)
            }
            LazyVGrid(columns: gridItems) {
                ForEach(Array(trackAndArtist.tracks), id: \.self) { song in
                    TrackView(song: song)
                }
            }
            HStack {
                Text("Your Top 5 Artists for the last 6 months:")
                    .padding()
                    .font(.title)
                Spacer()
                Button("View More") {
                    dataState = .artist
                    viewState = .top
                }
                .buttonStyle(.borderless)
                .padding(5)
                .padding(.trailing)
            }
            LazyVGrid(columns: gridItems) {
                ForEach(Array(trackAndArtist.artists), id: \.self) { artist in
                    ArtistView(artist: artist)
                }
            }

        }
        .padding()
        .onAppear {
            getPlaylist()
        }
        .onDisappear {
            playlists.removeAll()
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
