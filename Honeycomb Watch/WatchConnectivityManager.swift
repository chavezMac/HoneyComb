//
//  WatchConnectivityManager.swift
//  Honeycomb Watch
//
//  Receives favorites from the iPhone so the Watch shows the same list (simulator and device).
//

import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {
    var onFavoritesReceived: (([Favorite]) -> Void)?

    override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated, let data = session.receivedApplicationContext["favorites"] as? Data else { return }
        DispatchQueue.main.async { [weak self] in
            self?.applyReceived(data)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext["favorites"] as? Data else { return }
        DispatchQueue.main.async { [weak self] in
            self?.applyReceived(data)
        }
    }

    private func applyReceived(_ data: Data) {
        guard let favorites = try? JSONDecoder().decode([Favorite].self, from: data) else { return }
        onFavoritesReceived?(favorites)
    }
}
