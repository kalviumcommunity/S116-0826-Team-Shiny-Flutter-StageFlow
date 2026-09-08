# StageSync

> A Flutter mobile application for coordinating theatre productions, auditions, cast assignments, rehearsal schedules, venue bookings, availability, and scheduling conflicts.

**Squad:** S116  
**Team:** Team Shiny  
**Tech Stack:** Flutter + Dart + Firebase  
**Repository:** `S116-0826-Team-Shiny-Flutter-StageFlow`

> **Naming note:** The supplied Product Requirements Document uses **StageSync** as the product name, while the team's repository and current UI use **StageFlow**. This README uses **StageFlow** as the project name and preserves the PRD terminology where relevant.

---

## 📌 Project Overview

Regional theatre groups often coordinate multiple productions through group chats and scattered documents. As productions increase, it becomes difficult to keep schedules synchronized, resulting in missed schedule changes, venue double-bookings, cast commitment conflicts, and no consolidated view of commitments.

**StageFlow** centralizes the production workflow into one mobile application.

The MVP focuses on:

- Productions
- Auditions
- Roles and characters
- Cast assignments
- Rehearsals and performances
- Venue bookings
- Cast availability
- Schedule views
- Conflict detection
- Role-aware access

The supplied PRD defines Firebase Authentication, Cloud Firestore, Firebase Storage, real-time updates, and conflict prevention as core technical requirements. fileciteturn11file0

---

## 🎯 Problem Statement

A regional theatre group manages auditions, rehearsal schedules, and cast assignments across several simultaneous productions. Coordination through group chats becomes difficult as productions increase.

This can lead to:

- Missed schedule changes.
- Overlapping rehearsal or performance events.
- Venue double-bookings.
- Cast members being assigned to conflicting events.
- No consolidated view of production commitments.

StageFlow addresses these problems through a centralized theatre-management workflow.

---

## 👥 Target Users

### Director — Primary User

Directors manage productions and can create/edit productions, manage roles, assign cast members, create events and auditions, and monitor conflicts.

### Cast Member

Cast members can view assigned productions and roles, view upcoming events, view their schedule, and sign up for auditions.

### Admin — Stretch Goal

An optional administrative role can manage users and roles if included in the stretch scope.

---

## 🚀 MVP Features

| Feature | Priority | Description |
|---|---|---|
| Authentication | MVP | Email/password sign-up, login, logout and persistent sessions |
| Productions CRUD | MVP | Create, read, update and delete productions |
| Roles / Characters | MVP | Create/edit roles and assign cast members |
| Scheduling / Events | MVP | Create and manage rehearsals, performances and other events |
| Venue Conflict Detection | MVP | Prevent overlapping events at the same venue and time |
| Cast Conflict Detection | MVP | Detect overlapping events for selected cast members |
| Auditions | MVP | Create auditions and allow cast members to sign up |
| Home Dashboard | MVP | Show greeting, production information, counts and upcoming events |
| Schedule View | MVP | View events by date or production |
| Profile & Roles | MVP | Display user identity and role |
| Admin Panel | Stretch | Manage users and roles |
| Calendar Integration | Stretch | Optional Google Calendar integration |
| Notifications | Stretch | Push notifications for schedule changes |
| Search / Filter | Stretch | Search/filter productions and events |

The feature priorities above follow the supplied PRD. fileciteturn11file0

---

## 📱 UI / UX

The current StageFlow UI is mobile-first and follows a clean theatre-management SaaS direction.

### Core Screens

1. Splash
2. Login
3. Sign Up
4. Home Dashboard
5. Productions List
6. Production Detail
7. Roles / Characters
8. Schedule / Events
9. Create/Edit Production
10. Create/Edit Role
11. Create/Edit Event
12. Auditions List
13. Audition Sign-up
14. Schedule — All Productions
15. Profile
16. Optional Admin Panel

Some screens may be implemented as tabs, dialogs, or sheets depending on the final Flutter UX. The PRD describes approximately 14–16 distinct views. fileciteturn11file0

### Current UI Baseline

The Stitch-generated UI establishes the visual baseline:

- Light workspace surfaces.
- Stage Red for primary actions and critical conflicts.
- Compact cards.
- Status chips.
- Persistent bottom navigation.
- Dashboard-first information hierarchy.
- Clear conflict states.

Reusable Flutter components should preserve this visual language across all screens.

---

## ⚠️ Conflict Detection

Conflict prevention is one of the core product capabilities.

### Venue Conflict

When creating an event, the application checks whether another event already uses the same venue on the same date and whether the start/end times overlap.

```text
Create Event
     ↓
Same venue + same date?
     ↓
Check overlapping times
     ↓
   Conflict?
   /      \
 YES      NO
  ↓         ↓
Block     Save
```

### Cast Conflict

For every selected cast member, the application checks existing events for that cast member on the same date and detects overlapping times.

```text
Select Cast
     ↓
Find existing events
     ↓
Check same date + time overlap
     ↓
   Conflict?
   /      \
 YES      NO
  ↓         ↓
Warn      Continue
```

### Conflict UX

Every conflict should make it immediately clear:

- **Who** is affected.
- **What** is conflicting.
- **When** it occurs.
- **Where** it occurs.
- **What action** can resolve it.

The PRD explicitly requires that conflicting events not be saved and describes Firestore transaction-based checking for venue and cast conflicts. fileciteturn11file0

---

## 🗃️ Firebase Data Model

The PRD defines a simple Firestore structure:

```text
Firestore
│
├── users/{userId}
│   ├── name
│   ├── email
│   ├── role
│   └── photoUrl
│
└── productions/{productionId}
    ├── title
    ├── description
    ├── startDate
    ├── endDate
    ├── directorId
    ├── imageUrl
    │
    ├── roles/{roleId}
    │   ├── name
    │   └── assignedUserId
    │
    ├── events/{eventId}
    │   ├── start
    │   ├── end
    │   ├── type
    │   ├── venue
    │   └── castIds[]
    │
    └── auditions/{auditionId}
        ├── date
        ├── time
        ├── venue
        ├── castingFor
        └── castIds[]
```

Production poster images are stored in Firebase Storage, with the resulting download URL stored in the production document. fileciteturn11file0

---

## 🔐 Authentication & Authorization

The MVP uses Firebase Authentication with email/password.

### Authentication Flow

```text
Splash
  ↓
Check Firebase Auth State
  ↓
Authenticated?
 /          \
YES          NO
 ↓            ↓
Home        Login
              ↓
            Sign Up
```

The user's application role is stored in their Firestore user document.

Expected roles:

- `director`
- `cast`
- `admin` — optional/stretch

The PRD specifies role-aware access, including director-only production management and authenticated access to appropriate production/event data. fileciteturn11file0

---

## 🧱 Flutter Project Structure

The project should keep UI, state, data models, repositories/services, and utilities separated.

```text
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_text_styles.dart
│       └── app_spacing.dart
│
├── models/
│   ├── user_model.dart
│   ├── production_model.dart
│   ├── role_model.dart
│   ├── event_model.dart
│   └── audition_model.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
│
├── repositories/
│   ├── user_repository.dart
│   ├── production_repository.dart
│   ├── event_repository.dart
│   └── audition_repository.dart
│
├── screens/
│   ├── splash/
│   ├── auth/
│   │   ├── login/
│   │   └── signup/
│   ├── home/
│   ├── productions/
│   │   ├── production_list/
│   │   ├── production_detail/
│   │   ├── create_edit_production/
│   │   └── roles/
│   ├── schedule/
│   ├── auditions/
│   ├── profile/
│   └── admin/
│
├── widgets/
│   ├── app_scaffold.dart
│   ├── app_bottom_navigation.dart
│   ├── app_bar.dart
│   ├── production_card.dart
│   ├── event_card.dart
│   ├── status_chip.dart
│   ├── conflict_card.dart
│   ├── stat_card.dart
│   └── activity_item.dart
│
├── utils/
│   ├── validators.dart
│   ├── date_utils.dart
│   └── conflict_utils.dart
│
└── constants/
    └── app_constants.dart
```

This structure is an implementation recommendation based on the PRD's separation of models, services, screens, widgets and utilities. The PRD specifically mentions Flutter state management using ChangeNotifier and Provider as a simple recommended approach. fileciteturn11file0

---

## 🎨 Design System

### Visual Direction

```text
Primary Accent
Stage Red

Workspace
Soft Light / Near White

Text
Dark Navy

Supporting States
Green  → Available / Resolved
Amber  → Attention / Tentative
Red    → Conflict / Critical
```

### Reusable Components

- `AppScaffold`
- `AppBottomNavigation`
- `ProductionCard`
- `EventCard`
- `StatCard`
- `StatusChip`
- `ConflictCard`
- `ActivityItem`
- `SearchField`
- `FilterChip`
- `ConflictResolutionSheet`

### UX Principle

> **StageFlow should feel calm when everything is normal and immediately obvious when something needs attention.**

---

## 🛠️ Technology Stack

### Frontend

- Flutter
- Dart
- Material Design

### Backend / Cloud

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging — Stretch

### Development

- Git
- GitHub
- Pull Requests
- Feature/documentation branches

---

## 🗓️ Development Roadmap

The PRD defines an 8-week development roadmap. fileciteturn11file0

| Week | Focus |
|---|---|
| 1 | Product definition, wireframes, Flutter setup and Firebase project |
| 2 | Flutter scaffold, routing, bottom navigation and basic screens |
| 3 | Forms, validation and authentication foundation |
| 4 | Firebase Authentication and role handling |
| 5 | Production data model, CRUD and production screens |
| 6 | Event CRUD, Firestore real-time updates and Storage |
| 7 | Roles, cast assignment, schedule conflict logic and auditions |
| 8 | Testing, security rules, deployment preparation and demo |

---

## 🧪 Testing Strategy

### Unit Tests

Test business logic such as:

- Venue conflict detection.
- Cast conflict detection.
- Date/time validation.
- Form validation.
- Role logic.

### Widget Tests

Test UI behavior such as:

- Login validation.
- Correct navigation.
- Production card rendering.
- Conflict state rendering.

### Acceptance Tests

Important scenarios include:

- Director creates a production.
- Director creates a role and assigns a cast member.
- Director creates an event.
- Venue overlap is blocked.
- Cast overlap is detected.
- Cast member signs up for an audition.
- Schedule updates are visible.
- Unauthorized users cannot modify protected resources.

The PRD explicitly calls for unit tests, widget tests and manual/acceptance scenarios covering these workflows. fileciteturn11file0

---

## 🔒 Security

Firestore Security Rules are part of the required project scope.

The rules should enforce that:

- Users can access their own user information.
- Directors can manage their permitted productions.
- Only authorized users can create/update protected resources.
- Cast members cannot modify director-only resources.
- Authentication is required for protected data.

The PRD includes a Firestore Rules outline and specifically calls for testing rules to prevent unauthorized writes. fileciteturn11file0

---

## 📦 Local Development Setup

### Prerequisites

Install:

- Flutter SDK
- Git
- Android Studio or another Android-capable development environment
- Firebase CLI / FlutterFire tooling as required

### Verify Flutter

```bash
flutter doctor
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Run tests

```bash
flutter test
```

Firebase project configuration should be added during the Firebase integration phase and should not be committed with private credentials or secrets.

---

## 🌿 Git Workflow

`main` is the default branch.

### Branch Naming

Use focused branches:

```text
feature/authentication
feature/productions
feature/scheduling
feature/conflict-detection
feature/auditions
feature/profile
fix/schedule-validation
docs/project-readme
```

### Commit Style

```text
feat: add production creation flow
feat: add venue conflict detection
fix: validate overlapping cast events
docs: update project README
test: add conflict detection tests
```

### Pull Request Flow

```text
Create branch
    ↓
Implement
    ↓
Test
    ↓
Commit
    ↓
Push
    ↓
Open Pull Request
    ↓
Review
    ↓
Merge into main
```

All meaningful changes should go through Pull Requests rather than direct feature work on `main`.

---

## 📁 Repository Structure

As implementation progresses, the repository is expected to look approximately like:

```text
S116-0826-Team-Shiny-Flutter-StageFlow/
│
├── lib/
├── test/
├── assets/
│   ├── images/
│   └── icons/
│
├── android/
├── ios/
├── web/
├── windows/
├── macos/
├── linux/
│
├── docs/
│   ├── prd/
│   ├── ux/
│   ├── architecture/
│   └── api/
│
├── firebase/
│   ├── firestore.rules
│   └── firestore.indexes.json
│
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── .gitignore
```

Platform folders will depend on the Flutter targets enabled for the project.

---

## 👨‍💻 Team Charter

### Team

**Team Shiny**

### Squad

**S116**

### Working Agreement

- Communicate blockers early.
- Maintain regular GitHub activity.
- Use branches instead of directly pushing feature work to `main`.
- Create Pull Requests for changes.
- Review teammates' PRs.
- Test changes before merging.
- Keep commits focused and meaningful.
- Keep the repository organized.
- Keep documentation updated as implementation changes.

---

## 📊 MVP Success Criteria

The MVP should demonstrate that:

- A user can authenticate successfully.
- A director can create and manage productions.
- Roles and cast members can be assigned.
- Events can be created and viewed.
- Venue conflicts are detected and prevented.
- Cast conflicts are detected and surfaced.
- Auditions can be created and joined.
- Users can view their relevant schedules.
- Firestore rules enforce the intended access model.
- Core workflows run on a real Android/iOS device or emulator.

The PRD's success metrics include preventing conflicting events, consolidating schedules, and validating core functionality through acceptance testing. fileciteturn11file0

---

## 🎬 Demo Story

The recommended demonstration follows one continuous scenario:

```text
1. Director logs in
       ↓
2. Creates / opens a production
       ↓
3. Adds roles and assigns cast
       ↓
4. Creates a rehearsal
       ↓
5. Attempts an overlapping venue booking
       ↓
6. StageFlow detects the conflict
       ↓
7. Director resolves the conflict
       ↓
8. Cast member opens their schedule
       ↓
9. Updated schedule is visible
       ↓
10. Audition flow is demonstrated
```

This demonstrates the central product value: **bringing theatre coordination into one place and preventing scheduling problems before they happen.**

---

## 📚 Documentation

Project documentation should be maintained under:

```text
docs/
├── prd/
├── ux/
├── architecture/
└── api/
```

The supplied PRD covers the product scope, user stories, Firebase data model, authentication, storage, UI/UX sitemap, conflict logic, state management, roadmap, testing, deployment and demo requirements. fileciteturn11file0

---

## 📝 Current Project Status

**Phase:** Project setup → Flutter frontend implementation

### Priorities

- [ ] Establish Flutter application structure
- [ ] Implement StageFlow UI baseline
- [ ] Implement authentication
- [ ] Implement production CRUD
- [ ] Implement roles and cast assignment
- [ ] Implement scheduling
- [ ] Implement venue conflict detection
- [ ] Implement cast conflict detection
- [ ] Implement auditions
- [ ] Connect Firebase
- [ ] Add automated tests
- [ ] Validate Firestore security rules
- [ ] Prepare final demo

---

## 👥 Team

### Team Shiny — S116

| Member | Role | Responsibilities |
|---|---|---|
| **[Kanishka]** | **Frontend & UI/UX Lead** | Flutter UI implementation, Stitch design integration, reusable widgets, navigation, responsive layouts, theme and design system |
| **[Digvijay]** | **Backend & Firebase Lead** | Firebase Authentication, Firestore, Storage, data models, repositories/services, real-time data and security rules |
| **[Yashraj]** | **Features, Integration & QA Lead** | Scheduling, auditions, cast/venue conflict detection, conflict resolution, frontend-backend integration, testing and deployment |

### Role Ownership

#### 🎨 Frontend & UI/UX Lead
- Implement the StageFlow UI/UX in Flutter.
- Translate the Stitch designs into reusable Flutter components.
- Maintain the application theme, typography, spacing and visual consistency.
- Build navigation, screens and shared UI components.
- Handle loading, empty, error, conflict and success states.

#### 🔥 Backend & Firebase Lead
- Configure and maintain Firebase services.
- Implement Firebase Authentication and role handling.
- Design and maintain Firestore collections and data models.
- Implement Firebase Storage for production assets.
- Develop repositories/services and real-time data access.
- Write and maintain Firestore Security Rules and indexes.

#### ⚙️ Features, Integration & QA Lead
- Implement scheduling and event workflows.
- Implement auditions and cast assignment workflows.
- Develop venue and cast conflict detection.
- Build conflict resolution workflows.
- Integrate Flutter screens with backend services.
- Write unit/widget tests and perform acceptance testing.
- Support deployment and final demo preparation.

> **Note:** Role ownership defines the primary responsibility for each area. Team members should collaborate on integration, code reviews, testing and major architectural decisions.
| TBD | TBD | TBD |

Update this table once the final team member roles are confirmed.

---

## 📌 Repository

```text
S116-0826-Team-Shiny-Flutter-StageFlow
```

**Project:** StageFlow  
**Squad:** S116  
**Team:** Team Shiny  
**Frontend:** Flutter / Dart  
**Backend:** Firebase

---

### Product Requirements Source

This README is based on the team's supplied **StageSync — Product Requirements Document**, including its MVP scope, user stories, data model, security requirements, UI/UX sitemap, conflict logic, development roadmap, testing strategy and deployment checklist.
