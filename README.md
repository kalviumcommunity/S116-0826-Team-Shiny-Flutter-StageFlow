# StageSync — Theatre Production Management Mobile Application

StageSync is a complete, production-grade Flutter/Dart mobile application built for theatre companies, directors, and cast members. It replaces scattered messaging groups and lost schedules with a single, role-aware system featuring conflict-free scheduling, role management, audition boards, and Firebase persistence.

---

## 1. System Requirements & Architecture

* **Framework:** Flutter (SDK `>=3.10.0 <4.0.0`)
* **Language:** Dart (`>=3.0.0 <4.0.0`)
* **Design System:** Android Material 3 (Burgundy `#8B1E3F` & Stage Gold `#D4AF37`)
* **Backend:** Firebase (Authentication, Cloud Firestore, Firebase Storage)
* **State Management:** `provider` (`ChangeNotifier`)
* **Routing:** `go_router` (`StatefulShellRoute` with bottom navigation)
* **Primary Target:** Android & iOS mobile devices

### Clean Architecture Directory Layout

```text
lib/
├── main.dart                          # App entrypoint & MultiProvider setup
├── firebase_options.dart              # FlutterFire configuration
├── models/
│   ├── app_user.dart                  # User profile & role ('director' | 'cast')
│   ├── production.dart                # Production title, run dates, poster
│   ├── role_model.dart                # Character names & assigned cast
│   ├── event_model.dart               # Rehearsals, auditions, performances
│   └── audition.dart                  # Open audition calls & signups
├── services/
│   ├── auth_service.dart              # Firebase Auth signin/signup/state
│   ├── firestore_service.dart         # Firestore collections & subcollections
│   ├── storage_service.dart           # Firebase Storage poster uploads
│   └── conflict_service.dart          # Pure mathematical schedule conflict engine
├── providers/
│   ├── auth_provider.dart             # Session & role state
│   ├── production_provider.dart       # Production CRUD & casting state
│   └── schedule_provider.dart         # Master schedule & conflict enforcement
├── screens/
│   ├── splash/splash_screen.dart      # Branded launch screen
│   ├── auth/                          # Login & role-aware sign-up
│   ├── home/home_screen.dart          # Role-aware dashboard
│   ├── productions/                   # Productions list, create/edit, details
│   ├── schedule/                      # Master schedule & create/edit event
│   ├── auditions/                     # Auditions board & cast signup
│   └── profile/profile_screen.dart    # User profile & sign-out
├── widgets/                           # Reusable Material 3 cards & indicators
├── routing/app_router.dart            # GoRouter navigation configuration
├── theme/app_theme.dart               # Centralized Material 3 theme palette
└── utils/                             # DateTime formatters & form validators
```

---

## 2. Critical Feature — Conflict Detection Engine

The conflict engine in `lib/services/conflict_service.dart` strictly prevents double-booking using the mathematical rule:
$$\text{Event } A \text{ and } B \text{ overlap iff } A.start < B.end \text{ and } A.end > B.start$$

### Checks Performed Before Saving Any Event:

1. **Venue Conflict:** If another production has booked the same room (e.g. *Main Auditorium*) during an overlapping time window, saving is **blocked** with an explicit conflict dialog:
   ```text
   Venue Conflict
   Main Auditorium is already booked.
   Existing Event: Hamlet — Rehearsal
   Time: 6:00 PM – 8:00 PM
   Please choose another time or venue.
   ```
2. **Cast Conflict:** If any called cast member (e.g. *Sarah*) is already scheduled for an overlapping event across *any* production, saving is **blocked**:
   ```text
   Cast Conflict
   Sarah is already scheduled for:
   The Tempest — Rehearsal
   Time: 7:00 PM – 9:00 PM
   Please change the schedule or cast.
   ```
3. **Adjacent Intervals Allowed:** Touching sessions (e.g., 10:00–11:00 and 11:00–12:00) cleanly pass without false positives.

---

## 3. Firebase Setup Guide

### Step 1: Create Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `stagesync-app`.

### Step 2: Add Android Application
* **Package Name:** `com.stagesync.app` (configured in `android/app/build.gradle` and `AndroidManifest.xml`).
* Download `google-services.json` and place it in `android/app/google-services.json`.

### Step 3: Enable Authentication
1. Navigate to **Build > Authentication > Sign-in method**.
2. Enable **Email/Password**.

### Step 4: Provision Cloud Firestore
1. Navigate to **Build > Firestore Database > Create Database**.
2. Select your nearest cloud region (e.g., `nam5` or `asia-east1`).
3. Start in test mode or production mode.

### Step 5: Provision Firebase Storage
1. Navigate to **Build > Storage > Get Started**.
2. Default rules will store production posters under `posters/{productionId}.jpg`.

### Step 6: Configure FlutterFire CLI
Run from the root of this project:
```bash
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase options
flutterfire configure
```
This automatically updates `lib/firebase_options.dart` with your live Firebase keys.

### Step 7: Deploy Security Rules
Deploy the included `firestore.rules` and `storage.rules`:
```bash
firebase deploy --only firestore:rules,storage
```

---

## 4. Running the Application

### Install Dependencies
```bash
flutter pub get
```

### Run on Android Emulator or Device
```bash
flutter run -d android
```

### Run on iOS Simulator (macOS)
```bash
flutter run -d ios
```

---

## 5. Running the Tests

Run the unit test suite covering conflict overlap mathematics, edge conditions, and validators:
```bash
flutter test test/conflict_service_test.dart
flutter test test/validators_test.dart
```

---

## 6. College Demonstration Walkthrough

### Director Flow
1. Launch app $\rightarrow$ Sign in using `ananya.director@stagesync.app` (or click Director demo button).
2. On Dashboard, tap **+** or navigate to **Productions** $\rightarrow$ **New Production**.
3. Enter title `"Hamlet"`, select run dates, choose poster, tap **Save**.
4. In Hamlet details $\rightarrow$ **Roles & Cast** tab:
   - Add `"Hamlet"` $\rightarrow$ Assign to **John**.
   - Add `"Ophelia"` $\rightarrow$ Assign to **Sarah**.
   - Add `"Claudius"` $\rightarrow$ Leave **Unassigned**.
5. Switch to **Schedule** tab $\rightarrow$ tap **+**:
   - Type: `Rehearsal`
   - Venue: `Main Auditorium`
   - Time: `6:00 PM – 8:00 PM`
   - Cast: Select **Sarah** and **John** $\rightarrow$ tap **Save**.
6. **Trigger Conflict Test:**
   - Tap **+** to schedule another event at `Main Auditorium` from `7:00 PM – 9:00 PM`.
   - Tap **Save** $\rightarrow$ Observe **Venue Conflict dialog** blocking duplicate venue booking!
   - Change venue to `Room 201`, keep Sarah selected $\rightarrow$ Observe **Cast Conflict dialog** blocking Sarah from being double-booked!

### Cast Member Flow
1. Sign out $\rightarrow$ Sign in using `sarah.cast@stagesync.app`.
2. Dashboard immediately reflects assigned calls for Sarah.
3. Open **Audition Board** $\rightarrow$ View open audition call $\rightarrow$ Tap **Sign Up**.
4. Sign out and sign back in as Director $\rightarrow$ Notice Sarah listed under audition sign-ups in real-time.
