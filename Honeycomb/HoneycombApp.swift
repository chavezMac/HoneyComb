//
//  HoneycombApp.swift
//  Honeycomb
//
//  Companion iOS app for Honeycomb Watch app.
//

import SwiftUI

@main
struct HoneycombApp: App {
    @StateObject private var store = FavoritesStore()

    init() {
        WatchConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    WatchConnectivityManager.shared.push(favorites: store.favorites)
                }
        }
    }
}
