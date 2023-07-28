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
    
    @State var limit = 10
    
    let limits = [5,10,15,20,25,30,35,40,45,50]
    let timeRanges: [TimeRange] = [.shortTerm, .mediumTerm, .longTerm]
    
    @State var timeRange = TimeRange.mediumTerm
    
    func getTopArists(offset: Int = 0, limit: Int = 10, timeRange: TimeRange = .mediumTerm) {
        spotify.api.currentUserTopArtists(timeRange ,offset: offset, limit: limit)
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
    func getTopSongs(offset: Int = 0, limit: Int = 10, timeRange: TimeRange = .mediumTerm) {
        spotify.api.currentUserTopTracks(timeRange, offset: offset, limit: limit)
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
                Text("Your top")
                    .font(.largeTitle)
                    .padding(.leading)
                Picker(selection: $limit, label: EmptyView()) {
                    ForEach(limits, id: \.self) { limit in
                        Text(String(limit))
                            .font(.title2)
                    }
                }
                .frame(width:65, height: 50)
//                .scaledToFit()
                
                Button("Artist"){
                    withAnimation {
                        if dataState != .artist {
                            dataState = .artist
                            if artists.isEmpty {
                                getTopArists(limit: limit, timeRange: timeRange)
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
                                getTopSongs(limit: limit, timeRange: timeRange)
                            }
                        }
                    }
                    print(dataState)
                }
                .buttonStyle(.borderless)
                .font(.largeTitle)
                .foregroundColor(dataState == .songs ? .white : .gray)
                Picker(selection: $timeRange) {
                    ForEach(timeRanges, id: \.self) { range in
                        if range == .mediumTerm {
                            Text("Last 6 months")
                        }
                        else if range == .shortTerm {
                            Text("Last 4 weeks")
                        }
                        else {
                            Text("A long time")
                        }
                    }
                    
                } label: {
                    Text("For the previous:")
                        .font(.largeTitle)
                }
                .frame(width:300)
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
            .onChange(of: limit) { newLimit in
                print(limit)
                    getTopSongs(limit: limit, timeRange: timeRange)
                    getTopArists(limit: limit, timeRange: timeRange)
            }
            .onChange(of: timeRange) { range in
//                if dataState == .songs {
                    getTopSongs(limit: limit, timeRange: timeRange)
//                }
//                else {
                    getTopArists(limit: limit, timeRange: timeRange)
//                }
            }
        }
        .onChange(of: spotify.viewState) { state in
            print(state)
            if state == .top {
                getTopArists(limit: limit, timeRange: timeRange)
            }
        }
    }
}

struct TopDataView_Previews: PreviewProvider {
    static var previews: some View {
        TopDataView()
    }
}
