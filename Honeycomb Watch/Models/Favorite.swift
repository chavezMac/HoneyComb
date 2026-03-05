//
//  Favorite.swift
//  Honeycomb Watch
//
//  A contact or group favorite shown as a bubble in the honeycomb.
//

import Foundation

struct Favorite: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    /// One or more phone numbers (digits only). Single contact = one element; group = multiple.
    var phoneNumbers: [String]
    /// Unread message count for badge (not provided by system Messages API; set manually or via future API).
    var unreadCount: Int

    /// Single contact (backward compatible).
    var phoneNumber: String { phoneNumbers.first ?? "" }

    var isGroup: Bool { phoneNumbers.count > 1 }

    init(id: UUID = UUID(), name: String, phoneNumber: String, unreadCount: Int = 0) {
        self.id = id
        self.name = name
        self.phoneNumbers = [phoneNumber.filter { $0.isNumber }]
        self.unreadCount = max(0, unreadCount)
    }

    init(id: UUID = UUID(), name: String, phoneNumbers: [String], unreadCount: Int = 0) {
        self.id = id
        self.name = name
        self.phoneNumbers = phoneNumbers.map { $0.filter { $0.isNumber } }.filter { !$0.isEmpty }
        self.unreadCount = max(0, unreadCount)
    }

    enum CodingKeys: String, CodingKey { case id, name, phoneNumber, phoneNumbers, unreadCount }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        if let numbers = try c.decodeIfPresent([String].self, forKey: .phoneNumbers) {
            phoneNumbers = numbers.map { $0.filter { $0.isNumber } }.filter { !$0.isEmpty }
        } else {
            let single = try c.decode(String.self, forKey: .phoneNumber)
            phoneNumbers = [single.filter { $0.isNumber }]
        }
        unreadCount = try c.decodeIfPresent(Int.self, forKey: .unreadCount) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(phoneNumbers, forKey: .phoneNumbers)
        try c.encode(unreadCount, forKey: .unreadCount)
    }

    /// URL to open Messages to this contact or group on watchOS.
    var messagesURL: URL? {
        let digitsList = phoneNumbers.map { $0.filter { $0.isNumber } }.filter { !$0.isEmpty }
        guard !digitsList.isEmpty else { return nil }
        let addresses = digitsList.joined(separator: ",")
        return URL(string: "sms:/open?addresses=\(addresses)")
    }

    /// Label for bubble: groups = name (abbreviated); single = "J Reed" or first name.
    var bubbleLabel: String {
        if isGroup {
            let n = name.trimmingCharacters(in: .whitespaces)
            if n.count <= 4 { return n }
            return String(n.prefix(4))
        }
        let parts = name.trimmingCharacters(in: .whitespaces).split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if parts.count >= 2 {
            let first = parts[0]
            let last = parts[1]
            if let initial = first.first {
                return "\(String(initial).uppercased()) \(last)"
            }
            return String(last)
        }
        return parts.first.map(String.init) ?? "?"
    }

    /// True when we show first name only or group name (longer text → use smaller font).
    var bubbleLabelIsFirstNameOnly: Bool {
        if isGroup { return true }
        let parts = name.trimmingCharacters(in: .whitespaces).split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        return parts.count < 2
    }
}
