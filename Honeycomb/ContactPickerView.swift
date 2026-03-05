//
//  ContactPickerView.swift
//  Honeycomb
//
//  Presents the system contact picker; on selection adds a Favorite to the shared store.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    let onPick: (Favorite) -> Void
    var onCancel: (() -> Void)?

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView

        init(_ parent: ContactPickerView) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let name = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
            let phone: String = (contact.phoneNumbers.first?.value.stringValue ?? "")
                .filter { $0.isNumber }
            let normalized = phone.hasPrefix("1") && phone.count == 11 ? phone : (phone.count == 10 ? "1" + phone : phone)
            let favorite = Favorite(name: name.isEmpty ? "Unknown" : name, phoneNumber: normalized)
            parent.onPick(favorite)
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.onCancel?()
        }
    }
}
