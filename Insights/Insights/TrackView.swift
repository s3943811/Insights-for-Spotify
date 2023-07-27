//
//  TrackView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 27/7/2023.
//

import SwiftUI
import SpotifyWebAPI
import SpotifyExampleContent

struct TrackView: View {
    @State private var isHovering = false
    var song: Track
    var body: some View {
        Button {
            print("Song: \(song.name)")
        } label: {
            ZStack(alignment: .bottom) {
                let image = song.album!.images![0].url
                AsyncImage(url: image) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    case .failure(_):
                        Image(systemName: "questionmark")
                            .symbolVariant(.circle)
                            .font(.largeTitle)
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 150, height: 150)
                .scaleEffect(isHovering ? 1.2 : 1.0)
                
                VStack {
                    Text(song.name)
                        .lineLimit(2)
                        .font(.headline)
                    ForEach(song.artists!, id: \.self) { artist in
                        Text(artist.name)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(5)
                .frame(width: 150)
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

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView(song: .faces)
    }
}
