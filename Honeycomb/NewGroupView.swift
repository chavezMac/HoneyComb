//
//  NewGroupView.swift
//  Honeycomb
//
//  Create a group favorite (multiple recipients) for the Watch bubble.
//

import SwiftUI

struct NewGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    @State private var members: [Favorite] = []
    @State private var showContactPicker = false
    let onSave: (Favorite) -> Void

    private var canSave: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty && members.count >= 2
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group name", text: $groupName)
                        .textContentType(.none)
                        .autocapitalization(.words)
                } header: {
                    Text("Name")
                }

                Section {
                    ForEach(members) { member in
                        HStack {
                            Text(member.name)
                            Spacer()
                            Text(member.phoneNumber)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: removeMembers)
                    Button {
                        showContactPicker = true
                    } label: {
                        Label("Add member", systemImage: "person.badge.plus")
                    }
                } header: {
                    Text("Members")
                } footer: {
                    Text("Add at least 2 people. Tapping the bubble on Watch will open a group message.")
                }
            }
            .navigationTitle("New group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .fullScreenCover(isPresented: $showContactPicker) {
                ContactPickerView(
                    onPick: { favorite in
                        let digits = favorite.phoneNumber.filter { $0.isNumber }
                        if !digits.isEmpty, !members.contains(where: { $0.phoneNumber.filter { $0.isNumber } == digits }) {
                            members.append(favorite)
                        }
                        showContactPicker = false
                    },
                    onCancel: { showContactPicker = false }
                )
            }
        }
    }

    private func removeMembers(at offsets: IndexSet) {
        members.remove(atOffsets: offsets)
    }

    private func save() {
        let name = groupName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, members.count >= 2 else { return }
        let numbers = members.map { fav in
            let p = fav.phoneNumber.filter { $0.isNumber }
            return p.hasPrefix("1") && p.count == 11 ? p : (p.count == 10 ? "1" + p : p)
        }
        let group = Favorite(name: name, phoneNumbers: numbers)
        onSave(group)
        dismiss()
    }
}
