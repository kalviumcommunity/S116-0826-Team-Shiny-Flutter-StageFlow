# StageSync — Theatre Production Management Mobile Application

StageSync is a production management mobile application built with Flutter and Firebase designed for theatrical stage managers, directors, cast members, and crew. It streamlines production workflows, rehearsal call schedules, auditions, and role casting while enforcing a double-booking conflict detection engine.

---

## Architecture & Tech Stack

StageSync follows a strict MVVM (Model-View-ViewModel) architecture with a decoupled Service layer:

```text
UI (Screens & Common Widgets)
             ↓
ViewModels (ChangeNotifier only, constructor-injected services)
             ↓
Services (Firebase SDK encapsulation; no UI imports)
             ↓
Firebase Cloud Services (Auth, Cloud Firestore, Cloud Storage)
```

* **Framework:** Flutter 3.x / Dart 3 (Null-safe, Material 3 enabled)
* **State Management:** `provider` (`ChangeNotifierProvider`) exclusively
* **Navigation:** `go_router` with declarative routing and reactive auth guards
* **Backend:** Cloud Firestore (Real-time NoSQL), Firebase Authentication (Email/Password), Firebase Storage
* **Typography & Design:** Google Fonts (`Inter`), Theatrical visual identity with Deep Charcoal (`#1E2229`), Warm Spotlight Amber (`#F59E0B`), and Crimson Conflict Red (`#DC2626`)
* **Testing:** `flutter_test` + `mocktail` for zero-Firebase-dependency unit and widget tests

---

## Prerequisites

Before running or deploying StageSync, ensure you have the following installed:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+ stable channel)
* [Dart SDK](https://dart.dev/get-dart)
* [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
* [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (`dart pub global activate flutterfire_cli`)
* Android Studio or Xcode (for emulator or device testing)

---

## Installation & Setup

### 1. Clone & Fetch Dependencies
```bash
git clone <repository-url>
cd S116-0826-Team-Shiny-Flutter-StageFlow
flutter pub get
```

### 2. Configure Firebase
1. Log into your Firebase account:
   ```bash
   firebase login
   ```
2. Link your Firebase project and generate `lib/firebase_options.dart`:
   ```bash
   flutterfire configure
   ```
3. In the [Firebase Console](https://console.firebase.google.com/):
   * Enable **Authentication** -> **Email/Password** provider.
   * Create a **Cloud Firestore** database.
   * Create a **Firebase Storage** bucket.

### 3. Deploy Security Rules & Indexes
Deploy all security rules and composite queries before first use:
```bash
firebase deploy --only firestore:rules,storage:rules,firestore:indexes
```

---

## Running the Application

Launch the app on a connected emulator or physical device:
```bash
flutter run
```

---

## Running Tests & Static Analysis

StageSync includes unit and widget test suites mocking all Firebase services:

```bash
# Run all unit and widget tests
flutter test

# Run static analysis
flutter analyze

# Format code
dart format .
```

---

## Key Features & Invariants

### 1. Two-Tier Role System
* **Director:** Can create/edit/delete productions, manage character roles, schedule rehearsals and calls, schedule audition slots, and view attendance rosters.
* **Cast Member:** Read-only access to assigned productions, view call times on per-production and global master calendars, and self-service sign up for open audition slots.
* There is **no Administrator role** in the MVP.

### 2. Transactional Event Conflict Detection Engine
To prevent embarrassing double-bookings during rehearsals:
* All candidate conflict reads and final writes execute inside an **atomic Firestore transaction**.
* **Venue Conflict:** Rejects events at the same venue and calendar day where time intervals overlap:
  $$\text{candidate.start} < \text{new.end} \quad \text{and} \quad \text{candidate.end} > \text{new.start}$$
* **Cast Conflict:** Rejects events if any called cast member has an overlapping commitment on that day.
* **Adjacency:** Consecutive events that meet at exact boundary times (e.g., 2:00–4:00 PM and 4:00–6:00 PM) are permitted.
* **Normalization:** Venues are normalized (`venueKey = venue.trim().toLowerCase()`) to prevent bypass via whitespace or casing differences.
* **Warning UI:** Surfaced via a warning `ErrorBanner` that prevents screen pop so directors can immediately adjust call times.

### 3. Cross-Production Master Schedule
* Automatically aggregates scheduled calls across every production the current user is an active member of.
* Grouped by calendar day and chronologically sorted.

### 4. Monotonic Security Indexing (`memberIds`)
* Every production maintains a `memberIds` array containing the director and all assigned cast members.
* Whenever an actor is assigned a role, scheduled for a call, or signs up for an audition, their UID is added via atomic `arrayUnion`.
* Firestore security rules leverage this field for fast, single-document authorization checks without expensive cross-collection joins.

---

## Known Limitations & MVP Scope

* **No Push Notifications:** Rehearsal reminders are viewed in-app; push notifications are planned for a future release.
* **No External Calendar Sync:** Export to Google Calendar / Apple iCal is out of scope for the MVP.
* **Client-Enforced Conflict Invariant:** Conflict validation runs inside a client-side transaction. Firestore security rules cannot re-verify arbitrary time-range queries across documents; this is an accepted and documented MVP trust boundary.
* **Free-Text Venue Matching:** Venue conflict detection matches on exact normalized strings (`venueKey`). A centralized venue catalog is a future enhancement.
* **Client-Side Recursive Production Deletion:** Deleting a production removes child roles, events, and auditions in batched client-side commits. At commercial scale, this should transition to a Cloud Function.

---

## Documentation References
* [SECURITY_RULES.md](file:///c:/Projects/S116-0826-Team-Shiny-Flutter-StageFlow/SECURITY_RULES.md) — Comprehensive plain-English security and permissions breakdown.
* [DEPLOYMENT_CHECKLIST.md](file:///c:/Projects/S116-0826-Team-Shiny-Flutter-StageFlow/DEPLOYMENT_CHECKLIST.md) — Pre-flight audit checklist for grading and deployment.
