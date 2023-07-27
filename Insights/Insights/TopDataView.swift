//
//  TopDataView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 26/7/2023.
//

import SwiftUI
import SpotifyWebAPI

struct TopDataView: View {
    @EnvironmentObject var spotify: envSpotify

    @State private var dataState = DataChoice.artist
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 160, maximum: 230)),
    ]
    
    @State var artists = [Artist]()
    @State var songs = [Track]()
    
    func getTopArists(offset: Int = 0, limit: Int = 10) {
        spotify.api.currentUserTopArtists(offset: offset, limit: limit)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { results in
                    artists = results.items
                }
            )
            .store(in: &spotify.cancellables)
    }
    func getTopSongs(offset: Int = 0, limit: Int = 10) {
        spotify.api.currentUserTopTracks(offset: offset, limit: limit)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { results in
                    songs = results.items
                }
            )
            .store(in: &spotify.cancellables)
    }
    
    var body: some View {
        VStack{
            HStack {
                Text("Your top 10")
                    .font(.largeTitle)
                    .padding(.leading)
                Button("Artist"){
                    withAnimation {
                        if dataState != .artist {
                            dataState = .artist
                            if artists.isEmpty {
                                getTopArists()
                            }
                        }
                    }
                    print(dataState)
                }
                .buttonStyle(.borderless)
                .font(.largeTitle)
                .foregroundColor(dataState == .artist ? .white : .gray)
                
                Text("/")
                    .font(.largeTitle)
                Button("Songs:"){
                    withAnimation {
                        if dataState != .songs {
                            dataState = .songs
                            if songs.isEmpty {
                                getTopSongs()
                            }
                        }
                    }
                    print(dataState)
                }
                .buttonStyle(.borderless)
                .font(.largeTitle)
                .foregroundColor(dataState == .songs ? .white : .gray)
                
                Spacer()
            }
            ZStack {
                ScrollView() {
                    LazyVGrid(columns: gridItems) {
                        ForEach(artists, id: \.self) { artist in
                            ArtistView(artist: artist)
                        }
                    }
                    .padding()
                }
                .padding()
                .opacity(dataState == .artist ? 1.0 : 0)
                
                ScrollView() {
                    LazyVGrid(columns: gridItems) {
                        ForEach(songs, id: \.self) { song in
                            TrackView(song: song)
                        }
                    }
                    .padding()
                }
                .padding()
                .opacity(dataState == .songs ? 1.0 : 0)
            }
        }
        .onChange(of: spotify.viewState) { state in
            print(state)
            if state == .top {
                getTopArists()
            }
        }
    }
}

struct TopDataView_Previews: PreviewProvider {
    static var previews: some View {
        TopDataView()
    }
}
