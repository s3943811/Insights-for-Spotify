//
//  CardView.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 3/8/2023.
//

import SwiftUI
import SpotifyWebAPI

struct CardView: View {
    @Environment(\.openURL) var openURL
    
    @State private var isHovering = false
    var cardItem: CardItem
    
    var body: some View {
        Button {
            print(cardItem.name)
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: cardItem.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    case .failure(_), .empty:
                        Image(systemName: cardItem.systemImage)
                            .symbolVariant(.circle)
                            .font(.largeTitle)
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 130, height: 130)
                .scaleEffect(isHovering ? 1.2 : 1.0)
                
                VStack {
                    Text(cardItem.name)
                        .lineLimit(2)
                        .font(.headline)
                    if cardItem.typeofItem == .track {
                        if let artists = cardItem.artists {
                            ForEach(artists, id: \.self) { artist in
                                Text(artist.name)
                                    .lineLimit(2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else if cardItem.typeofItem == .playlist {
                        if let owner = cardItem.owner {
                            Text("By: \(owner.id)")
                                .lineLimit(1)
                                .font(.headline)
                        }
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

struct CardView_Previews: PreviewProvider {
    static let cardItem = CardItem()
    static var previews: some View {
        CardView(cardItem: cardItem)
    }
}
