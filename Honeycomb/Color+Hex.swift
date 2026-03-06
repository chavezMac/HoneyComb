//
//  Color+Hex.swift
//  Honeycomb
//
//  Hex string conversion for saving/loading favorite bubble color.
//

import SwiftUI
import UIKit

extension Color {
    /// Creates a Color from a hex string (e.g. "#FF5733" or "FF5733").
    init?(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard s.count == 6 else { return nil }
        let r = Double((Int(s.prefix(2), radix: 16) ?? 0)) / 255
        let g = Double((Int(s.dropFirst(2).prefix(2), radix: 16) ?? 0)) / 255
        let b = Double((Int(s.suffix(2), radix: 16) ?? 0)) / 255
        self.init(red: r, green: g, blue: b)
    }

    /// Returns a hex string (e.g. "#FF5733") for persistence.
    func toHex() -> String? {
        let uic = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uic.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
