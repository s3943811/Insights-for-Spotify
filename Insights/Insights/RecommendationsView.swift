//
//  RecommendationsView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 31/7/2023.
//

import SwiftUI
import SpotifyWebAPI

struct RecommendationsView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var spotify: envSpotify
    @Binding var currentUser: SpotifyUser
    @State var recommendations = Set<Track>()
    @State var attributes = [TrackAttributes]()
//    @State var currentUser: SpotifyUser? = nil
    @State var currPlaylist: Playlist<PlaylistItems>? = nil
    @Binding var trackAndArtist: TrackAndArtist
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 130)),
    ]

    func getRecommendations(attributes: [TrackAttributes], isRefresh: Bool = false) {
        if isRefresh {
            recommendations.removeAll()
        }
        spotify.api.recommendations(attributes[0], limit: 10)
            .sink(
                receiveCompletion: { completion in
                    print(completion, "1")
                },
                receiveValue: { results in
                    recommendations = recommendations.union(results.tracks)
                }
            )
            .store(in: &spotify.cancellables)
        spotify.api.recommendations(attributes[1], limit: 10)
            .sink(
                receiveCompletion: { completion in
                    print(completion, "2")
                },
                receiveValue: { results in
                    recommendations = recommendations.union(results.tracks)
                }
            )
            .store(in: &spotify.cancellables)
    }
    func createPlaylist() {
        let playlistDetails = PlaylistDetails(name: "Insights-Recommendation",
                                             isPublic: false,
                                             isCollaborative: false,
                                             description: "A playlist of recommendations from insights")
        spotify.api.createPlaylist(for: currentUser.uri, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    print(completion, "2")
                },
                receiveValue: { results in
                    currPlaylist = results
                }
            )
            .store(in: &spotify.cancellables)
    }
    func addItemsToPlaylist() {
        guard let playlistURI = currPlaylist?.uri else {return}
        var uris = [String]()
        for item in recommendations {
            uris.append(item.uri!)
        }
        spotify.api.addToPlaylist(playlistURI, uris: uris)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { _ in
                }
            )
            .store(in: &spotify.cancellables)
    }
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Some Recommendations:")
                    .font(.largeTitle)
                    .padding(.top, 3)
                    .padding(5)
                Button {
                    withAnimation {
                        getRecommendations(attributes: attributes, isRefresh: true)
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .font(.title3)
                Spacer()
                Button {
                    createPlaylist()
                } label: {
                    Label("Create Playlist", systemImage: "rectangle.stack.badge.plus")
                }
                .padding()
            }
            .onChange(of: currPlaylist) { _ in
                addItemsToPlaylist()
            }
            ScrollView() {
                LazyVGrid(columns: gridItems) {
                    ForEach(Array(recommendations), id: \.self) { song in
                        TrackView(song: song)
                    }
                }
                .padding()
            }
            
        }
        .onAppear {
//            getCurrentUser()
            var artistURIs = [String]()
            for item in trackAndArtist.artists {
                artistURIs.append(item.uri!)
            }
            attributes.append(TrackAttributes(seedArtists: artistURIs))
            var songURIs = [String]()
            for item in trackAndArtist.tracks {
                songURIs.append(item.uri!)
            }
            attributes.append(TrackAttributes(seedTracks: songURIs))
            getRecommendations(attributes: attributes)
        }
        .onDisappear {
            recommendations.removeAll()
        }
    }
}

//struct RecommendationsView_Previews: PreviewProvider {
//    static var trackA = TrackAndArtist(tracks: [.time], artists: [.crumb])
//    static var previews: some View {
//        RecommendationsView(trackAndArtist: $trackA)
//    }
//}
