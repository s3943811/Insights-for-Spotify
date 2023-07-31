//
//  PlaylistView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 31/7/2023.
//

import SwiftUI
import SpotifyWebAPI
import SpotifyExampleContent

struct PlaylistView: View {
    @Environment(\.openURL) var openURL
    
    @State private var isHovering = false
    var playlist: Playlist<PlaylistItemsReference>
    var body: some View {
        Button {
            if let url = playlist.externalURLs?["spotify"] {
                openURL(url)
            }
        } label: {
            ZStack(alignment: .bottom) {
//                let image = song.album?.images?[1].url
                if !playlist.images.isEmpty {
                    let image = playlist.images[0].url
                    AsyncImage(url: image) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        case .failure(_):
                            Image(systemName: "music.quarternote.3")
                                .symbolVariant(.circle)
                                .font(.largeTitle)
                        default:
                            ProgressView()
                        }
                    }
                    .frame(width: 130, height: 130)
                    .scaleEffect(isHovering ? 1.2 : 1.0)
                } else {
                    Image(systemName: "music.quarternote.3")
                        .symbolVariant(.circle)
                        .font(.largeTitle)
                        .frame(width: 130, height: 130)
                        .scaleEffect(isHovering ? 1.2 : 1.0)
                }
                
                VStack {
                    Text(playlist.name)
                        .lineLimit(2)
                        .font(.headline)
                    if let owner = playlist.owner {
                        Text("By: \(owner.id)")
                            .lineLimit(1)
                            .font(.headline)
                    }
                }
                .padding(3)
                .frame(width: 130)
                .background(.regularMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.borderless)
        .overlay(isHovering ? RoundedRectangle(cornerRadius: 8)
            .stroke(.secondary, lineWidth: 2) : nil)
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }

    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(playlist: .lucyInTheSkyWithDiamonds)
    }
}

