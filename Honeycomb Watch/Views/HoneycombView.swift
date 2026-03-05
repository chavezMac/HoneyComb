//
//  HoneycombView.swift
//  Honeycomb Watch
//
//  Free-flowing radial bubble layout (like Watch app home); tap opens Messages.
//

import SwiftUI

struct HoneycombView: View {
    @EnvironmentObject var store: FavoritesStore
    @Environment(\.openURL) private var openURL

    /// Bubble diameter and minimum gap so bubbles never touch.
    private let bubbleSize: CGFloat = 44
    private let minGap: CGFloat = 6
    /// Minimum center-to-center distance (bubble + gap).
    private var minCenterDistance: CGFloat { bubbleSize + minGap }

    /// Radii chosen so same-ring arc spacing and ring separation are both >= minCenterDistance.
    private func innerRadius(for innerCount: Int) -> CGFloat {
        guard innerCount > 0 else { return 0 }
        return minCenterDistance * CGFloat(innerCount) / (2 * .pi)
    }
    private func outerRadius(for outerCount: Int, innerR: CGFloat) -> CGFloat {
        let minForArc = outerCount > 0 ? minCenterDistance * CGFloat(outerCount) / (2 * .pi) : 0
        return max(minForArc, innerR + minCenterDistance)
    }

    /// Content size so outer ring + bubble radius fits with padding.
    private var contentSize: CGFloat {
        let innerCount = min(4, max(1, store.favorites.count))
        let outerCount = max(0, store.favorites.count - innerCount)
        let innerR = innerRadius(for: innerCount)
        let outerR = outerRadius(for: outerCount, innerR: innerR)
        return 2 * (outerR + bubbleSize / 2 + 20)
    }

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                let center = contentSize / 2
                let positions = radialPositions(count: store.favorites.count)
                ForEach(Array(store.favorites.enumerated()), id: \.element.id) { index, favorite in
                    let pt = positions.indices.contains(index) ? positions[index] : CGPoint(x: center, y: center)
                    BubbleButton(favorite: favorite) {
                        store.markAsRead(favorite)
                        openMessages(for: favorite)
                    }
                    .frame(width: bubbleSize, height: bubbleSize)
                    .position(x: pt.x, y: pt.y)
                }
            }
            .frame(width: contentSize, height: contentSize)
        }
        .navigationTitle("Messages")
        .onAppear { store.load() }
    }

    /// Free-flowing positions: inner ring + outer ring; spacing ensures no overlap or touch.
    private func radialPositions(count: Int) -> [CGPoint] {
        let center = contentSize / 2
        guard count > 0 else { return [CGPoint(x: center, y: center)] }
        var points: [CGPoint] = []
        let innerCount = min(4, count)
        let outerCount = count - innerCount
        let innerR = innerRadius(for: innerCount)
        let outerR = outerRadius(for: outerCount, innerR: innerR)
        let innerAngleOffset: CGFloat = 0.12
        for i in 0..<innerCount {
            let angle = -CGFloat.pi / 2 + (2 * CGFloat.pi / CGFloat(innerCount)) * CGFloat(i) + innerAngleOffset
            points.append(CGPoint(
                x: center + innerR * cos(angle),
                y: center + innerR * sin(angle)
            ))
        }
        for i in 0..<outerCount {
            let angle = -CGFloat.pi / 2 + (2 * CGFloat.pi / CGFloat(outerCount)) * CGFloat(i) - 0.2
            points.append(CGPoint(
                x: center + outerR * cos(angle),
                y: center + outerR * sin(angle)
            ))
        }
        return points
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
                    Circle()
                        .fill(.tint)
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
