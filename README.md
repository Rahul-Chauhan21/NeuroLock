# NeuroLock

An iOS application designed for ADHD-focused productivity. NeuroLock uses Apple's Screen Time APIs to introduce **Manifold Friction**—a dynamic blocking system that escalates resistance when impulsive behavior is detected.

## 🚀 Key Features

- **Escalation Engine:** Three levels of friction that increase as you attempt to bypass blocks.
  - **Level 1 (Gentle Nudge):** Mild prompt, short 5-minute bypass allowed.
  - **Level 2 (Guilt Trip):** Harsher messaging, orange warning UI.
  - **Level 3 (Annoyance Protocol):** Strict block. Bypassing requires opening the main app, waiting out a **60-second timer**, and typing a **guilt-inducing pledge** perfectly.
- **Interactive Home Screen Widget:** Start or stop focus sessions instantly with a single tap using iOS 17+ App Intents.
- **Strict Blocking:** Leverages `FamilyControls`, `ManagedSettings`, and `DeviceActivity` for system-level app and website shielding.
- **Privacy First:** Uses Apple's opaque tokens; the app never sees your private browsing or app usage data.

## 🏗️ Architecture

NeuroLock is built with a multi-target architecture to navigate iOS sandboxing:

1.  **Main App (SwiftUI/MVVM):** The control center for permissions, app selection, and the "Annoyance Protocol" manual override.
2.  **Shared Logic (`FocusShared.swift`):** A centralized module used by all targets to ensure a single source of truth for session state and escalation levels.
3.  **Shield Configuration Extension:** Dynamically generates the block screen UI (prompts, colors, buttons) based on the current escalation level.
4.  **Shield Action Extension:** Intercepts taps on the block screen, increments the escalation level, and enforces the "no-bypass" rule at Level 3.
5.  **Widget Extension:** Provides the interactive Home Screen button for session control.

## 🛠️ Technical Implementation Details

- **App Group (`group.com.rc.NeuroLock.shared`):** Used for low-latency data sharing between the app and its extensions via `UserDefaults`.
- **State Syncing:** The main app uses a 1-second polling timer to sync state changes (like escalation increments) that happen inside the background Shield extensions.
- **ManagedSettingsStore:** Programmatically applies and clears shields without requiring a system-level schedule.

## 📋 Requirements & Setup

- **Hardware:** Requires a physical iOS device (Screen Time APIs are not functional in the Simulator).
- **Capabilities:**
  - Family Controls (Screen Time)
  - App Groups
- **Target Membership:** `FocusShared.swift` must be included in all target memberships to avoid scope errors.

---
*Created with Gemini CLI - Focus through friction.*
