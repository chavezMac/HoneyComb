//
//  ContentView.swift
//  Honeycomb
//
//  Manage favorites on iPhone; they sync to Watch via App Group.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FavoritesStore
    @State private var showContactPicker = false
    @State private var editingFavorite: Favorite?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.favorites) { favorite in
                        HStack {
                            Text(favorite.name)
                            if favorite.isGroup {
                                Image(systemName: "person.2.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if favorite.unreadCount > 0 {
                                Text(favorite.unreadCount > 99 ? "99+" : "\(favorite.unreadCount)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(.red))
                            }
                            Spacer()
                            Text(favorite.isGroup ? "\(favorite.phoneNumbers.count) people" : favorite.phoneNumber)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingFavorite = favorite
                        }
                        .contextMenu {
                            Button("Edit color & ring") {
                                editingFavorite = favorite
                            }
                            Button("Mark as read") {
                                store.markAsRead(favorite)
                            }
                            if favorite.unreadCount > 0 { Divider() }
                            Section("Set unread (for demo)") {
                                ForEach([1, 2, 3, 5, 10], id: \.self) { n in
                                    Button("\(n) unread") {
                                        store.setUnreadCount(n, for: favorite.id)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: store.remove)
                } header: {
                    Text("Watch bubbles")
                } footer: {
                    Text("These contacts appear as bubbles on Watch. Unread badges sync to Watch; Apple doesn't provide real unread counts from Messages, so use the context menu to set unread for demo.")
                }

                Section {
                    Button {
                        showContactPicker = true
                    } label: {
                        Label("Add from Contacts", systemImage: "person.crop.circle.badge.plus")
                    }
                    NavigationLink {
                        NewGroupView { group in
                            store.add(group)
                        }
                    } label: {
                        Label("Create group", systemImage: "person.2.badge.gearshape")
                    }
                }
            }
            .navigationTitle("Honeycomb")
            .sheet(isPresented: $showContactPicker) {
                ContactPickerView(
                    onPick: { favorite in
                        if !store.contains(phoneNumber: favorite.phoneNumber) {
                            store.add(favorite)
                        }
                        showContactPicker = false
                    },
                    onCancel: { showContactPicker = false }
                )
            }
            .sheet(item: $editingFavorite) { favorite in
                EditFavoriteSheet(
                    favorite: favorite,
                    onSave: { hexColor, ringIndex in
                        store.setHexColor(hexColor, for: favorite.id)
                        store.setRingIndex(ringIndex, for: favorite.id)
                        editingFavorite = nil
                    },
                    onCancel: { editingFavorite = nil }
                )
            }
        }
    }
}

// MARK: - Edit favorite (color & ring)

struct EditFavoriteSheet: View {
    let favorite: Favorite
    let onSave: (String?, Int) -> Void
    let onCancel: () -> Void

    @State private var selectedColor: Color
    @State private var useDefaultColor: Bool
    @State private var ringIndex: Int

    private let maxRing = 5

    init(favorite: Favorite, onSave: @escaping (String?, Int) -> Void, onCancel: @escaping () -> Void) {
        self.favorite = favorite
        self.onSave = onSave
        self.onCancel = onCancel
        let useDefault = favorite.hexColor == nil
        _useDefaultColor = State(initialValue: useDefault)
        _selectedColor = State(initialValue: (favorite.hexColor.flatMap { Color(hex: $0) }) ?? .orange)
        _ringIndex = State(initialValue: min(favorite.ringIndex, 5))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(favorite.name)
                        .font(.headline)
                } header: {
                    Text("Contact")
                }

                Section {
                    Toggle("Use default color", isOn: $useDefaultColor)
                    if !useDefaultColor {
                        ColorPicker("Hexagon color", selection: $selectedColor, supportsOpacity: false)
                    }
                } header: {
                    Text("Color")
                } footer: {
                    Text("Default uses the system accent on Watch.")
                }

                Section {
                    Picker("Ring", selection: $ringIndex) {
                        ForEach(0...maxRing, id: \.self) { index in
                            Text(ringLabel(index)).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Ring on Watch")
                } footer: {
                    Text("Ring 1 is innermost (up to 4 contacts), then Ring 2 (8), Ring 3 (12), etc.")
                }
            }
            .navigationTitle("Edit bubble")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let hex = useDefaultColor ? nil : selectedColor.toHex()
                        onSave(hex, ringIndex)
                    }
                }
            }
        }
    }

    private func ringLabel(_ index: Int) -> String {
        if index == 0 { return "Ring 1 (inner)" }
        return "Ring \(index + 1)"
    }
}

#Preview {
    ContentView()
        .environmentObject(FavoritesStore())
}
