//
//  HoneycombView.swift
//  Honeycomb Watch
//
//  Radial honeycomb bubble layout; tap opens Messages.
//

import SwiftUI

// MARK: - Hexagon shape (flat-top, honeycomb style)

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        // Flat-top hexagon: height = 2R, width = R√3. Use R so hexagon fits in rect.
        let R = min(w / sqrt(3), h / 2)
        let cx = w / 2
        let cy = h / 2
        let s3 = sqrt(3)
        var path = Path()
        // Vertices from center: top, top-right, bottom-right, bottom, bottom-left, top-left.
        let points: [(CGFloat, CGFloat)] = [
            (0, -R),
            (R * s3 / 2, -R / 2),
            (R * s3 / 2, R / 2),
            (0, R),
            (-R * s3 / 2, R / 2),
            (-R * s3 / 2, -R / 2),
        ]
        path.move(to: CGPoint(x: cx + points[0].0, y: cy + points[0].1))
        for i in 1..<points.count {
            path.addLine(to: CGPoint(x: cx + points[i].0, y: cy + points[i].1))
        }
        path.closeSubpath()
        return path
    }
}

struct HoneycombView: View {
    @EnvironmentObject var store: FavoritesStore
    @Environment(\.openURL) private var openURL

    /// Bubble size and minimum gap so hexagons never touch.
    private let bubbleSize: CGFloat = 44
    private let minGap: CGFloat = 6
    /// Minimum center-to-center distance (hexagon + gap).
    private var minCenterDistance: CGFloat { bubbleSize + minGap }

    /// Ring capacities: inner ring 4, then 8, 12, 16, ...
    private static func count(onRing ringIndex: Int) -> Int { 4 * (ringIndex + 1) }

    /// Radii for each ring so arc spacing and ring separation are >= minCenterDistance.
    private func radiiForRings(ringCounts: [Int]) -> [CGFloat] {
        var radii: [CGFloat] = []
        for (index, n) in ringCounts.enumerated() {
            let minForArc = n > 0 ? minCenterDistance * CGFloat(n) / (2 * .pi) : 0
            let minFromPrev = radii.isEmpty ? minForArc : (radii.last! + minCenterDistance)
            radii.append(max(minForArc, minFromPrev))
        }
        return radii
    }

    /// Content size from the rings actually used (by favorite.ringIndex).
    private var contentSize: CGFloat {
        let radii = radiiForUserRings()
        let outerR = radii.last ?? 0
        return 2 * (outerR + bubbleSize / 2 + 20)
    }

    /// Radii for ring 0, 1, ... up to max ring index in use (capacity 4, 8, 12, ... per ring).
    private func radiiForUserRings() -> [CGFloat] {
        let maxRing = store.favorites.map(\.ringIndex).max() ?? 0
        let ringCounts = (0...maxRing).map { Self.count(onRing: $0) }
        return radiiForRings(ringCounts: ringCounts)
    }

    /// Pairs each favorite with its position based on favorite.ringIndex; preserves store order within each ring.
    private func favoritesWithPositions() -> [(Favorite, CGPoint)] {
        let center = contentSize / 2
        let radii = radiiForUserRings()
        guard !radii.isEmpty else { return [] }
        let topAngle = -CGFloat.pi / 2
        var result: [(Favorite, CGPoint)] = []
        let byRing = Dictionary(grouping: store.favorites, by: { $0.ringIndex })
        let sortedRings = byRing.keys.sorted()
        for r in sortedRings {
            guard r >= 0, r < radii.count else { continue }
            let favoritesOnRing = byRing[r] ?? []
            let n = favoritesOnRing.count
            guard n > 0 else { continue }
            let R = radii[r]
            let angleStep = (2 * .pi) / CGFloat(n)
            let offset = CGFloat(r) * 0.08
            for (i, fav) in favoritesOnRing.enumerated() {
                let angle = topAngle + angleStep * CGFloat(i) + offset
                let pt = CGPoint(x: center + R * cos(angle), y: center + R * sin(angle))
                result.append((fav, pt))
            }
        }
        return result
    }

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                let center = contentSize / 2
                let pairs = favoritesWithPositions()
                ForEach(pairs, id: \.0.id) { pair in
                    BubbleButton(favorite: pair.0) {
                        store.markAsRead(pair.0)
                        openMessages(for: pair.0)
                    }
                    .frame(width: bubbleSize, height: bubbleSize)
                    .position(x: pair.1.x, y: pair.1.y)
                }
            }
            .frame(width: contentSize, height: contentSize)
        }
        .navigationTitle("Messages")
        .onAppear { store.load() }
    }

    private func openMessages(for favorite: Favorite) {
        guard let url = favorite.messagesURL else { return }
        openURL(url)
    }
}

struct BubbleButton: View {
    let favorite: Favorite
    let action: () -> Void

    private let bubbleSize: CGFloat = 44

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Hexagon()
                        .fill(favorite.bubbleColor ?? Color.accentColor)
                        .frame(width: bubbleSize, height: bubbleSize)
                    Text(favorite.bubbleLabel)
                        .font(.system(size: fontSize, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                if favorite.unreadCount > 0 {
                    Text(badgeText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Circle().fill(.red))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var badgeText: String {
        favorite.unreadCount > 99 ? "99+" : "\(favorite.unreadCount)"
    }

    private var fontSize: CGFloat {
        if favorite.bubbleLabelIsFirstNameOnly {
            return 10
        }
        return 11
    }
}

#Preview {
    HoneycombView()
        .environmentObject(FavoritesStore())
}
