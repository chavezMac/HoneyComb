//
//  FavoritesStore.swift
//  Honeycomb Watch
//
//  Persists and provides the list of favorites for the honeycomb.
//

import Foundation
import SwiftUI

/// Watch uses local UserDefaults; sync from iPhone is via WatchConnectivity (App Group doesn't sync across devices/simulators).
private let favoritesKey = "honeycomb_favorites"

final class FavoritesStore: ObservableObject {
    private var defaults: UserDefaults { .standard }
    @Published var favorites: [Favorite] = []

    init() {
        load()
        if favorites.isEmpty {
            favorites = Self.defaultFavorites()
            save()
        }
    }

    func load() {
        guard let data = defaults.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([Favorite].self, from: data) else { return }
        favorites = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        defaults.set(data, forKey: favoritesKey)
    }

    func add(_ favorite: Favorite) {
        favorites.append(favorite)
        save()
    }

    func remove(at offsets: IndexSet) {
        favorites.remove(atOffsets: offsets)
        save()
    }

    func remove(_ favorite: Favorite) {
        favorites.removeAll { $0.id == favorite.id }
        save()
    }

    func setUnreadCount(_ count: Int, for favoriteId: UUID) {
        guard let i = favorites.firstIndex(where: { $0.id == favoriteId }) else { return }
        favorites[i].unreadCount = max(0, count)
        save()
    }

    func markAsRead(_ favorite: Favorite) {
        setUnreadCount(0, for: favorite.id)
    }

    /// Replace favorites with the list received from the iPhone (WatchConnectivity).
    func applyReceivedFromPhone(_ favorites: [Favorite]) {
        self.favorites = favorites
        save()
    }

    static func defaultFavorites() -> [Favorite] {
        [
            Favorite(name: "Jordan Reed", phoneNumber: "15551234001"),
            Favorite(name: "Sam Chen", phoneNumber: "15559876002"),
            Favorite(name: "Alex Rivera", phoneNumber: "15555551234"),
            Favorite(name: "Morgan Blake", phoneNumber: "15557654321"),
            Favorite(name: "Casey Kim", phoneNumber: "15558881234"),
            Favorite(name: "Riley Walsh", phoneNumber: "15552229876"),
            Favorite(name: "Quinn Foster", phoneNumber: "15553334455"),
            Favorite(name: "Taylor Hayes", phoneNumber: "15554445566"),
            Favorite(name: "Jamie Soto", phoneNumber: "15556667788"),
            Favorite(name: "Drew Patel", phoneNumber: "15557778899"),
            Favorite(name: "Family", phoneNumbers: ["15551234001", "15559876002"]),
        ]
    }
}
