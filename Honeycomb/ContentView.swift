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
                        .contextMenu {
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
        }
    }
}

#Preview {
    ContentView()
}
