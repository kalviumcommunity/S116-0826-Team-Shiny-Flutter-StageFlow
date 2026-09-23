# StageSync — Deployment & Verification Checklist

This checklist must be audited prior to grading, staging, or production rollout.

## Build & Quality
- [x] Flutter project builds cleanly
- [x] `flutter analyze` passes with zero errors
- [x] `flutter test` passes 100% of unit and widget tests
- [x] Null safety strictly maintained throughout
- [x] Material 3 enabled (`useMaterial3: true`)
- [x] Proper responsive keyboard handling with `SingleChildScrollView` on all forms

## Firebase Configuration
- [ ] Firebase project created in Firebase Console
- [ ] Email/Password authentication provider enabled
- [ ] Cloud Firestore database created in production mode
- [ ] Firebase Storage bucket created
- [ ] `flutterfire configure` executed locally to generate `firebase_options.dart`
- [ ] Firestore Security Rules deployed (`firebase deploy --only firestore:rules`)
- [ ] Storage Security Rules deployed (`firebase deploy --only storage:rules`)
- [ ] Firestore Composite Indexes deployed (`firebase deploy --only firestore:indexes`)

## Security & Secrets
- [x] Real Firebase secrets excluded from git (`.gitignore`)
- [x] `firebase_options.dart.example` provided for new developers
- [x] `.env` files excluded
- [x] Storage poster size limited to 5 MB and format restricted to JPEG/PNG
- [x] Posters restricted to authenticated production members
- [x] User profiles protected; only cast profiles readable for assignment dropdowns

## Core Architecture
- [x] Strict Layering: `UI -> ViewModel -> Service -> Firebase`
- [x] Zero direct Firebase SDK imports in UI (`screens/`, `widgets/`)
- [x] Zero direct Firebase SDK imports in ViewModels (`viewmodels/`)
- [x] State Management: `Provider` + `ChangeNotifier` ONLY (no Riverpod, BLoC, or GetX)
- [x] Declarative routing via `GoRouter` with named routes only
- [x] Exact Firestore schema compliance (`users`, `productions`, `roles`, `events`, `auditions`)

## MVP Functionality
- [x] User Sign-Up with role selection (Director vs Cast Member only; no Admin role)
- [x] User Sign-In with credential validation and friendly error mapping
- [x] Auth-gated routing (Splash -> Login -> Home with auto-redirect on logout)
- [x] Personalized greeting based on time of day and user name
- [x] Director-only `+ New Production` FAB and actions
- [x] Cast users restricted from director affordances (hidden FAB, read-only schedule/roles)
- [x] Production CRUD with poster upload to Firebase Storage
- [x] Cascading batch deletion for roles, events, and auditions upon production deletion
- [x] Role management: creation, assignment, and unassignment
- [x] Monotonic `memberIds` array maintenance for security rules optimization
- [x] Transactional event double-booking engine (venue & cast overlap prevention)
- [x] Warning banner (`isWarning: true`) upon schedule conflict without screen pop
- [x] Per-production schedule tab grouped by calendar day with type chips
- [x] Global master schedule aggregating events across all user productions
- [x] Audition slots management with cast sign-up and attendee roster
- [x] Distinct visual loading states vs empty states for all stream views
- [x] Async button disable and double-submit prevention

## Presentation & Demo
- [x] `README.md` complete with setup, build, test, and deployment commands
- [x] `SECURITY_RULES.md` complete with plain-English architecture explanations
- [ ] Demo director and cast accounts created
- [ ] Demo script rehearsed
