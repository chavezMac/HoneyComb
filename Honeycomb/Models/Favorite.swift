//
//  Favorite.swift
//  Honeycomb
//
//  Same model as Watch app; must stay in sync for App Group storage.
//

import Foundation

struct Favorite: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    /// One or more phone numbers (digits only). Single contact = one element; group = multiple.
    var phoneNumbers: [String]
    /// Unread message count for badge (not provided by system Messages API; set manually for now).
    var unreadCount: Int
    /// Hex color for Watch hexagon (e.g. "#FF5733"). Nil = use default tint.
    var hexColor: String?
    /// Which ring on Watch (0 = innermost, then 1, 2, ...).
    var ringIndex: Int

    /// Single contact (backward compatible).
    var phoneNumber: String { phoneNumbers.first ?? "" }

    var isGroup: Bool { phoneNumbers.count > 1 }

    init(id: UUID = UUID(), name: String, phoneNumber: String, unreadCount: Int = 0, hexColor: String? = nil, ringIndex: Int = 0) {
        self.id = id
        self.name = name
        self.phoneNumbers = [phoneNumber.filter { $0.isNumber }]
        self.unreadCount = max(0, unreadCount)
        self.hexColor = hexColor
        self.ringIndex = max(0, ringIndex)
    }

    init(id: UUID = UUID(), name: String, phoneNumbers: [String], unreadCount: Int = 0, hexColor: String? = nil, ringIndex: Int = 0) {
        self.id = id
        self.name = name
        self.phoneNumbers = phoneNumbers.map { $0.filter { $0.isNumber } }.filter { !$0.isEmpty }
        self.unreadCount = max(0, unreadCount)
        self.hexColor = hexColor
        self.ringIndex = max(0, ringIndex)
    }

    enum CodingKeys: String, CodingKey { case id, name, phoneNumber, phoneNumbers, unreadCount, hexColor, ringIndex }
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
        hexColor = try c.decodeIfPresent(String.self, forKey: .hexColor)
        ringIndex = try c.decodeIfPresent(Int.self, forKey: .ringIndex) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(phoneNumbers, forKey: .phoneNumbers)
        try c.encode(unreadCount, forKey: .unreadCount)
        try c.encodeIfPresent(hexColor, forKey: .hexColor)
        try c.encode(ringIndex, forKey: .ringIndex)
    }
}
