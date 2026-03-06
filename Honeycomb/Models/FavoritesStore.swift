//
//  FavoritesStore.swift
//  Honeycomb
//
//  Shared with Watch via App Group; add/remove favorites on iPhone.
//

import Foundation
import SwiftUI

private let appGroupSuite = "group.com.honeycomb.shared"
private let favoritesKey = "honeycomb_favorites"

final class FavoritesStore: ObservableObject {
    private var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupSuite) ?? .standard
    }
    @Published var favorites: [Favorite] = []

    init() {
        load()
    }

    func load() {
        guard let data = defaults.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([Favorite].self, from: data) else { return }
        favorites = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        defaults.set(data, forKey: favoritesKey)
        #if os(iOS)
        WatchConnectivityManager.shared.push(favorites: favorites)
        #endif
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

    func contains(phoneNumber: String) -> Bool {
        let digits = phoneNumber.filter { $0.isNumber }
        return favorites.contains { fav in
            fav.phoneNumbers.contains { $0.filter { $0.isNumber } == digits }
        }
    }

    func setUnreadCount(_ count: Int, for favoriteId: UUID) {
        guard let i = favorites.firstIndex(where: { $0.id == favoriteId }) else { return }
        favorites[i].unreadCount = max(0, count)
        save()
    }

    func markAsRead(_ favorite: Favorite) {
        setUnreadCount(0, for: favorite.id)
    }

    func setHexColor(_ hex: String?, for favoriteId: UUID) {
        guard let i = favorites.firstIndex(where: { $0.id == favoriteId }) else { return }
        favorites[i].hexColor = hex
        save()
    }

    func setRingIndex(_ ring: Int, for favoriteId: UUID) {
        guard let i = favorites.firstIndex(where: { $0.id == favoriteId }) else { return }
        favorites[i].ringIndex = max(0, ring)
        save()
    }
}
