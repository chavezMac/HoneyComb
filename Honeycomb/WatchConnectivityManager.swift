//
//  WatchConnectivityManager.swift
//  Honeycomb
//
//  Pushes favorites to the Watch so iPhone and Watch stay in sync (required for simulator and device).
//

import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Call after updating favorites so the Watch receives the latest list.
    func push(favorites: [Favorite]) {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isWatchAppInstalled else { return }
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        let context: [String: Any] = [
            "favorites": data,
            "ts": Date().timeIntervalSince1970,
        ]
        do {
            try WCSession.default.updateApplicationContext(context)
        } catch {
            // Failed to update application context, but we'll try again on next update
            print("Failed to update Watch application context: \(error)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}
