# Honeycomb

<p align="center">
  <img src="honeycomb.png" alt="Honeycomb app logo" width="120">
</p>

A watchOS companion app that shows your message favorites as a **bubble grid** (inspired by the Apple Watch app launcher). Tap a bubble to open the system Messages app to that contact or group—no digging through the stack.

- **iPhone:** Add single contacts or groups from your Contacts; manage the list and optional unread badges.
- **Watch:** Radial honeycomb layout of bubbles; tap to open Messages. Data syncs via WatchConnectivity.

Built with SwiftUI. Requires Xcode 15+, iOS 17+, and watchOS 10+.

---

## Features

- **Bubble grid on Watch** – Free-flowing radial layout (no rigid grid); each bubble is a favorite contact or group.
- **Single contacts & groups** – Add individuals from Contacts or create groups (2+ people); group bubbles open a group message.
- **Sync iPhone ↔ Watch** – Favorites and unread counts sync via WatchConnectivity (works on device and paired simulators).
- **Unread-style badges** – Optional red badge with count on bubbles (manual for now; Apple doesn’t expose real Messages unread data).
- **Opens Messages** – Uses `sms:/open?addresses=...` so tapping a bubble opens the system Messages app to that thread.

---

## Limitations (Apple’s APIs)

- **No access to Messages data** – Apple does not provide APIs to read the Messages app. Honeycomb cannot:
  - Auto-create bubbles from existing conversations.
  - Show real unread counts from iMessage (badges are manual/demo).
  - Know when you receive or start a new message.
- Favorites are **manually** added on the iPhone (Add from Contacts, Create group). The Watch only displays and opens Messages; it does not read your message list.

---

## Getting started

### Run in Xcode

1. Clone the repo and open `honeycomb.xcodeproj` in Xcode.
2. Select the **Honeycomb** scheme and an **iPhone** simulator or device.
3. Build and run (⌘R). Use a paired **Watch** simulator or device to see the bubble grid.

### Use on your iPhone and Apple Watch

1. **Signing:** Xcode → Settings → Accounts → add your Apple ID. For both **Honeycomb** and **Honeycomb Watch** targets, set **Signing & Capabilities** → **Team** to your account (free Apple ID works for personal devices).
2. **App Group:** Add the **App Groups** capability to both targets with the same group, e.g. `group.com.honeycomb.shared` (the project includes entitlement files; add the capability in the UI to link your team).
3. **Run to iPhone:** Choose your iPhone as the run destination and run. Trust the developer certificate on the device if prompted.
4. **Watch:** The Watch app installs with the iPhone app. If “Install” in the Watch app on iPhone fails, set the run destination to your **Apple Watch** and run again to install directly from Xcode.
5. **Add favorites:** On iPhone, open Honeycomb → **Add from Contacts** or **Create group**. They sync to the Watch; tap a bubble on the Watch to open Messages.

### Simulator (iPhone + Watch)

- Use a **paired** iPhone and Watch simulator. If they aren’t paired, use Terminal:  
  `xcrun simctl pair <WATCH_UDID> <IPHONE_UDID>`  
  (Get UDIDs from `xcrun simctl list devices available`.)
- Run the **Honeycomb** scheme on the iPhone simulator first, then run on the Watch simulator. Add a favorite on the iPhone to test sync.

---

## Project structure

| Target           | Role |
|------------------|------|
| **Honeycomb**    | iOS app: list of favorites, Add from Contacts, Create group, unread controls. Pushes data to Watch via WatchConnectivity. |
| **Honeycomb Watch** | watchOS app: radial bubble layout (`HoneycombView`), opens Messages via `sms:` URL. Receives favorites from iPhone. |

Shared concept: `Favorite` (name, `phoneNumbers[]`, optional unread count). Single contact = one number; group = multiple. Watch uses local UserDefaults; sync is over WatchConnectivity, not App Groups (iPhone and Watch don’t share the same storage).

---

## Unread badges

- **iPhone:** Long-press a favorite → **Set unread (for demo)** (1, 2, 3, 5, 10) or **Mark as read**.
- **Watch:** Tapping a bubble opens Messages and clears that bubble’s badge.

Real unread counts from iMessage are not available to third-party apps; the UI is ready if Apple ever exposes an API.

---

## Requirements

- Xcode 15+
- iOS 17+
- watchOS 10+

---

## License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE).

If you’d like to modify or build on Honeycomb, please **fork the repository** and make your changes in your fork. Pull requests are welcome.
