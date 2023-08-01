//
//  TopDataView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 26/7/2023.
//

import SwiftUI
import SpotifyWebAPI

struct UserTopView: View {
    @EnvironmentObject var spotify: envSpotify
    @Binding var viewState: ViewState
    @Binding var dataState: DataChoice
    @State var range = TimeRange.mediumTerm
    @State var artists = [Artist]()
    @State var songs = [Track]()
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 130)),
    ]
    
    var ranges = [TimeRange.shortTerm, TimeRange.mediumTerm, TimeRange.longTerm]
    
    func getTopArists(timeRange: TimeRange) {
        spotify.api.currentUserTopArtists(timeRange ,offset: 0, limit: 50)
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
    func getTopSongs(timeRange: TimeRange) {
        spotify.api.currentUserTopTracks(timeRange, offset: 0, limit: 50)
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
    
    func performSearch(time: TimeRange = TimeRange.mediumTerm) {
            if dataState == .songs {
                artists.removeAll()
                getTopSongs(timeRange: time)
            } else {
                songs.removeAll()
                getTopArists(timeRange: time)
            }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Your top")
                    .font(.largeTitle)
                    .padding(.leading)
                
                Button("Artist"){
                    withAnimation {
                        if dataState != .artist {
                            dataState = .artist
                        }
                    }
                    print(dataState)
                }
                .selectorButtonStyle(desiredState: .artist, currentState: dataState)
                
                Text("/")
                    .font(.largeTitle)
                Button("Songs:"){
                    withAnimation {
                        if dataState != .songs {
                            dataState = .songs
                        }
                    }
                    print(dataState)
                }
                .selectorButtonStyle(desiredState: .songs, currentState: dataState)
            }
            Picker("", selection: $range.animation(.easeIn)) {
                ForEach(ranges, id: \.self) { range in
                    Text(range == .mediumTerm ? "Last 6 Months" : range == .shortTerm ? "Last 4 Weeks" : "All Time")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 300)
            ScrollView() {
                ZStack {
                    LazyVGrid(columns: gridItems) {
                        ForEach(artists, id: \.self) { artist in
                            ArtistView(artist: artist)
                        }
                    }
                    .padding()
                    .opacity(dataState == .artist ? 1.0 : 0)
                    
                    LazyVGrid(columns: gridItems) {
                        ForEach(songs, id: \.self) { song in
                            TrackView(song: song)
                        }
                    }
                    .padding()
                    .opacity(dataState == .songs ? 1.0 : 0)
                }
                .onAppear() {
//                    print(state)
                    if viewState == .top {
                        performSearch(time: range)
                    }
                }
                .onDisappear {
                    if viewState != .top {
                        artists.removeAll()
                        songs.removeAll()
                    }
                }
                .onChange(of: range) { newRange in
                    performSearch(time: range)
                }
                .onChange(of: dataState) { newState in
                    performSearch(time: range)
                }
            }
        }
        
    }
}

struct SelectorButton: ViewModifier {
    let desiredState: DataChoice
    let currentState: DataChoice
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderless)
            .font(.largeTitle)
            .foregroundColor(currentState == desiredState ? .primary : .secondary)
            .underline(currentState == desiredState ? true : false, color: .primary)
        
    }
}

extension View {
    func selectorButtonStyle(desiredState: DataChoice, currentState: DataChoice) -> some View {
        modifier(SelectorButton(desiredState: desiredState, currentState: currentState))
    }
}

//struct UserTopView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserTopView(viewState: ViewState.top)
//    }
//}
