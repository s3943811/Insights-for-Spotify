//
//  InsightsApp.swift
//  Insights
//
//  Created by Maximus Dionyssopoulos on 25/7/2023.
//

import SwiftUI

@main
struct InsightsApp: App {
    @ObservedObject var spotify = envSpotify()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .handlesExternalEvents(preferring: ["pause"], allowing: ["*"])
                .frame(minWidth: 700, minHeight: 500)
                .environmentObject(spotify)
        }
    }
}
