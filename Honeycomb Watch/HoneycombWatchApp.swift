//
//  HoneycombWatchApp.swift
//  Honeycomb Watch
//
//  watchOS app: honeycomb bubble grid that opens Messages.
//

import SwiftUI

@main
struct HoneycombWatchApp: App {
    @StateObject private var store = FavoritesStore()
    @StateObject private var connectivity = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            HoneycombView()
                .environmentObject(store)
                .onAppear {
                    connectivity.onFavoritesReceived = { favorites in
                        store.applyReceivedFromPhone(favorites)
                    }
                    connectivity.activate()
                }
        }
    }
}
