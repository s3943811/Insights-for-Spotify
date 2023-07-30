//
//  CardView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 26/7/2023.
//

import SwiftUI
import SpotifyWebAPI
import SpotifyExampleContent

struct ArtistView: View {
    var artist: Artist
    
    @State private var isHovering = false
    
    
    var body: some View {
        Button {
            print("Artist: \(artist.name)")
        } label: {
            ZStack(alignment: .bottom) {
                let image = artist.images![1].url
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
                .frame(width: 130, height: 130)
                .scaleEffect(isHovering ? 1.2 : 1.0)
                
                VStack {
                    Text(artist.name)
                        .lineLimit(2)
                        .font(.headline)
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

struct ArtistView_Previews: PreviewProvider {
    static let artist: Artist = .radiohead
    static var previews: some View {
        ArtistView(artist: artist)
    }
}
