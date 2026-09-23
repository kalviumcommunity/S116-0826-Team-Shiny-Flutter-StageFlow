# 🎭 StageSync

> **A real-time theatre production management platform for productions, casting, auditions, schedules, venues, and conflict-free coordination.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter\&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart\&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase\&logoColor=black)](https://firebase.google.com/)
[![Firestore](https://img.shields.io/badge/Cloud%20Firestore-Database-FFCA28?logo=firebase\&logoColor=black)](https://firebase.google.com/docs/firestore)
[![Authentication](https://img.shields.io/badge/Firebase%20Auth-Authentication-FFCA28?logo=firebase\&logoColor=black)](https://firebase.google.com/docs/auth)
[![License](https://img.shields.io/badge/License-Educational-lightgrey)](#)

**Squad:** S116
**Team:** Team Shiny
**Repository:** `S116-0826-Team-Shiny-Flutter-StageFlow`

---

## ✨ What is StageSync?

StageSync is a **Flutter-based theatre production management application** designed to bring the day-to-day coordination of theatre productions into one place.

Regional theatre teams often manage productions through group chats, spreadsheets, phone calls, and scattered documents. As the number of productions grows, this makes it increasingly difficult to keep track of:

* 🎬 Productions
* 🎭 Roles and cast assignments
* 🎤 Auditions
* 📅 Rehearsals and performances
* 🏛️ Venue bookings
* 👥 Cast availability
* ⚠️ Scheduling conflicts
* 🔄 Real-time schedule changes

StageSync centralizes these workflows into a single mobile application backed by **Firebase Authentication, Cloud Firestore, and Firebase Storage**.

The goal is simple:

> **Make theatre coordination organized, real-time, and conflict-aware.**

The supplied PRD defines the MVP around production management, casting, event scheduling, auditions, authentication, real-time updates, and venue/cast conflict detection.

---

## 🎯 The Problem

Theatre productions involve many moving parts and people.

A single production can have:

* Multiple actors and crew members
* Multiple rehearsals
* Different venues
* Audition sessions
* Performances
* Changing schedules
* Overlapping commitments

When this information is distributed across conversations and documents, coordination becomes fragile.

### Common problems

| Problem                                       | Consequence                   |
| --------------------------------------------- | ----------------------------- |
| Schedule changes shared across multiple chats | People miss updates           |
| Two productions use the same venue            | Venue double-booking          |
| An actor is assigned to overlapping events    | Cast conflict                 |
| Auditions managed manually                    | Difficult attendance tracking |
| Cast lists stored in different places         | Poor visibility               |
| No central schedule                           | Difficult planning            |

StageSync addresses these problems through a centralized production workflow and automated conflict detection.

The project requirements explicitly identify missed schedule changes, overlapping events, venue double-bookings, and cast commitment conflicts as core coordination problems.

---

# 🚀 Core Features

## 🔐 Authentication

Secure user authentication powered by Firebase Authentication.

* Email/password sign-up
* Login
* Logout
* Persistent authentication state
* Role-aware application experience
* Director / Cast Member roles

---

## 🎬 Production Management

Directors can manage their productions from one place.

### Production capabilities

* Create productions
* Edit productions
* Delete productions
* View production details
* Define production dates
* Add descriptions
* Upload production poster images
* View associated roles
* View associated schedules

Production data is stored in Cloud Firestore, while production images are stored in Firebase Storage.

---

## 🎭 Roles & Casting

Manage the relationship between productions, characters, and performers.

Directors can:

* Create roles/characters
* Edit roles
* Assign cast members
* View assigned performers
* Identify unassigned roles

Cast members can view their assigned roles and associated productions.

---

## 🎤 Auditions

StageSync provides an integrated audition workflow.

### Directors

* Create auditions
* Define audition date/time
* Define venue
* Specify what is being cast
* View registered participants

### Cast Members

* Browse available auditions
* View audition details
* Sign up for auditions

The PRD defines audition sign-ups through a Firestore-backed participant list.

---

# 📅 Scheduling

StageSync provides a centralized schedule for production events.

Supported event types include:

* Rehearsals
* Auditions
* Performances
* Other production events

Each event can contain:

```text
Event
├── Date
├── Start Time
├── End Time
├── Type
├── Venue
├── Cast Members
└── Notes
```

Events are displayed chronologically and can be viewed within productions or through the user's overall schedule.

Firestore real-time listeners allow schedule information to update without requiring a manual refresh.

---

# ⚠️ Smart Conflict Detection

> **One of StageSync's core product capabilities.**

StageSync is designed to detect scheduling conflicts **before an event is saved**.

### 🏛️ Venue conflicts

The system checks whether another event is already using the selected venue during an overlapping time period.

```text
Create Event
     │
     ▼
Check Venue
     │
     ▼
Same venue + overlapping time?
     │
   ┌─┴─┐
  YES  NO
   │    │
   ▼    ▼
BLOCK  Continue
 SAVE    │
         ▼
       Save
```

### 👤 Cast conflicts

For every selected cast member, StageSync checks whether that person is already assigned to another overlapping event.

```text
Select Cast
     │
     ▼
Find Existing Events
     │
     ▼
Check Time Overlap
     │
   ┌─┴─┐
  YES  NO
   │    │
   ▼    ▼
 WARN  Continue
```

### Conflict information

When a conflict occurs, the UI should clearly communicate:

* **Who** is affected
* **What** event conflicts
* **When** the conflict occurs
* **Where** it occurs
* **What needs to change**

The PRD specifies querying overlapping events and preventing conflicting venue/cast bookings from being saved.

---

# 🧠 Conflict Detection Logic

The core scheduling rule is based on time overlap:

```text
Existing Event:
[start₁ ───────── end₁]

New Event:
       [start₂ ───────── end₂]

Conflict exists when:

start₁ < end₂
AND
end₁ > start₂
```

StageSync applies this logic to:

### Venue

```text
Same venue
    +
Same date
    +
Overlapping time
    =
Venue conflict
```

### Cast

```text
Same cast member
    +
Same date
    +
Overlapping time
    =
Cast conflict
```

The PRD proposes Firestore queries combined with transaction-based writes so that conflicting events are rejected rather than silently saved.

---

# 👥 User Roles

StageSync is designed around role-aware access.

| Role               | Primary Responsibilities                                     |
| ------------------ | ------------------------------------------------------------ |
| 🎬 **Director**    | Manage productions, roles, cast, events and auditions        |
| 🎭 **Cast Member** | View productions, roles, schedules and sign up for auditions |
| 🛠️ **Admin**      | User and role management — stretch scope                     |

The supplied executive summary also identifies **Stage Manager** as a potential operational role for scheduling, venue management, attendance and conflict resolution. This role is part of the broader system vision but is not required for the core MVP.

---

# 📱 Application Screens

The MVP is structured around a simple mobile-first navigation model.

### Authentication

1. Splash
2. Login
3. Sign Up

### Main Application

4. Home Dashboard
5. Productions
6. Production Details
7. Roles / Casting
8. Schedule
9. Create/Edit Production
10. Create/Edit Role
11. Create/Edit Event
12. Auditions
13. Audition Sign-up
14. Profile

### Stretch

15. Admin / User Management

The PRD describes approximately 13–14 core screens with bottom navigation and production-specific workflows.

---

# 🏠 Dashboard

The Home dashboard is intended to provide an immediate overview of production activity.

Depending on the user's role, it can surface:

* Greeting
* Active productions
* Cast counts
* Upcoming events
* Upcoming auditions
* Production information
* Schedule highlights

### Director view

```text
┌───────────────────────────────┐
│ Good morning, Director        │
│                               │
│ My Productions                │
│ ┌───────────────────────────┐ │
│ │ Hamlet                     │ │
│ │ 12 Cast · 4 Upcoming      │ │
│ └───────────────────────────┘ │
│                               │
│ Upcoming Events               │
│ • Rehearsal — 6:00 PM        │
│ • Production Meeting — 8 PM  │
└───────────────────────────────┘
```

### Cast view

The cast experience prioritizes:

* Assigned productions
* Assigned roles
* Upcoming events
* Auditions
* Personal schedule

---

# 🏗️ Architecture

StageSync follows a lightweight Flutter architecture designed to keep UI, business logic, and Firebase access separated.

```text
┌─────────────────────────────┐
│         Flutter UI          │
│ Screens + Widgets + Forms   │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       State Management      │
│     Provider / ChangeNotifier│
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│      Services / Repos       │
│ Auth · Firestore · Storage  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│           Firebase          │
│ Auth · Firestore · Storage  │
└─────────────────────────────┘
```

The PRD recommends **Provider + ChangeNotifier** for the MVP because the application does not require the additional complexity of Riverpod/BLoC.

---

# 🗃️ Firebase Data Model

StageSync uses Cloud Firestore as its primary application database.

```text
Firestore
│
├── users/{userId}
│   ├── name
│   ├── email
│   ├── role
│   └── photoURL
│
└── productions/{productionId}
    ├── title
    ├── description
    ├── startDate
    ├── endDate
    ├── directorId
    ├── imageURL
    │
    ├── roles/{roleId}
    │   ├── name
    │   └── assignedUserId
    │
    ├── events/{eventId}
    │   ├── date
    │   ├── start
    │   ├── end
    │   ├── type
    │   ├── venue
    │   ├── castIds[]
    │   └── notes
    │
    └── auditions/{auditionId}
        ├── date
        ├── time
        ├── venue
        └── castIds[]
```

This structure keeps production-specific data grouped beneath its production while keeping users in a separate collection for authentication and assignment workflows.

---

# 🔥 Firebase Stack

| Service                      | Purpose                                         |
| ---------------------------- | ----------------------------------------------- |
| **Firebase Authentication**  | User registration, login and sessions           |
| **Cloud Firestore**          | Productions, roles, events, auditions and users |
| **Firebase Storage**         | Production poster/media storage                 |
| **Firebase Cloud Messaging** | Notifications — stretch goal                    |

The core MVP is intentionally Firebase-first to keep the backend simple while providing real-time updates and authentication.

---

# 🔐 Security & Authorization

Firebase Authentication identifies users, while Firestore Security Rules enforce access boundaries.

### Intended access model

```text
Authenticated User
       │
       ▼
Read permitted data
       │
       ├── Director
       │      └── Manage owned productions
       │
       └── Cast
              └── View assigned data
                  + audition participation
```

Examples:

* Users can access their own profile.
* Directors can create and manage their productions.
* Only authorized users can modify roles/events.
* Cast members cannot modify director-only production resources.
* Protected resources require authentication.

The PRD provides a Firestore Rules outline based on the authenticated user's UID and production director ownership.

---

# 🎨 UI / UX Direction

StageSync follows a clean, mobile-first theatre-management interface.

### Design principles

* Clear information hierarchy
* Compact production cards
* Strong schedule visibility
* Status indicators
* Clear empty states
* Clear loading/error states
* Immediate conflict feedback
* Consistent navigation
* Minimal interaction complexity

### Visual language

```text
Primary
Stage Red

Workspace
Soft Light / Near White

Text
Dark Navy

States
Green  → Available / Resolved
Amber  → Attention
Red    → Conflict / Critical
```

### Core reusable components

```text
AppScaffold
AppBottomNavigation
ProductionCard
EventCard
StatCard
StatusChip
ConflictCard
ActivityItem
SearchField
FilterChip
ConflictResolutionSheet
```

> **Design principle:**
> StageSync should feel calm when everything is normal — and immediately obvious when something needs attention.

---

# 🧱 Project Structure

The application follows a feature-oriented Flutter structure with reusable services and widgets.

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
│   ├── home/
│   ├── productions/
│   ├── schedule/
│   ├── auditions/
│   ├── profile/
│   └── admin/
│
├── widgets/
│   ├── app_scaffold.dart
│   ├── app_bottom_navigation.dart
│   ├── production_card.dart
│   ├── event_card.dart
│   ├── status_chip.dart
│   ├── conflict_card.dart
│   └── stat_card.dart
│
├── utils/
│   ├── validators.dart
│   ├── date_utils.dart
│   └── conflict_utils.dart
│
└── constants/
    └── app_constants.dart
```

---

# 🛠️ Tech Stack

### Frontend

* **Flutter**
* **Dart**
* **Material Design**
* **Provider / ChangeNotifier**

### Backend

* **Firebase Authentication**
* **Cloud Firestore**
* **Firebase Storage**
* **Firebase Cloud Messaging** — stretch

### Development

* Git
* GitHub
* Pull Requests
* Flutter testing tools
* Firebase Console
* Firebase CLI / FlutterFire tooling

---

# ⚙️ Getting Started

## Prerequisites

Install:

* Flutter SDK
* Dart SDK
* Git
* Android Studio or another Android development environment
* Firebase CLI / FlutterFire tooling

Verify your Flutter installation:

```bash
flutter doctor
```

---

## 1. Clone the repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd S116-0826-Team-Shiny-Flutter-StageFlow
```

---

## 2. Install dependencies

```bash
flutter pub get
```

---

## 3. Configure Firebase

Connect the Flutter project to your Firebase project using FlutterFire.

Your Firebase configuration should include the services required by the application:

```text
Firebase Authentication
Cloud Firestore
Firebase Storage
```

Do **not** commit private credentials, secrets, or environment-specific sensitive configuration.

---

## 4. Run the application

```bash
flutter run
```

To select a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

---

## 5. Run tests

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

Format the project:

```bash
dart format .
```

---

# 🧪 Testing Strategy

Testing focuses on the workflows that matter most to production coordination.

## Unit Tests

Test business logic such as:

* Venue conflict detection
* Cast conflict detection
* Time overlap calculations
* Date validation
* Form validation
* Role logic

## Widget Tests

Test:

* Login validation
* Navigation
* Production cards
* Event cards
* Conflict states
* Forms
* Empty states

## Acceptance Tests

Critical scenarios include:

```text
✓ Director logs in
✓ Director creates production
✓ Director creates role
✓ Director assigns cast member
✓ Director creates event
✓ Venue conflict is blocked
✓ Cast conflict is detected
✓ Cast member signs up for audition
✓ Schedule updates appear
✓ Unauthorized writes are rejected
```

The supplied PRD explicitly calls for unit, widget and manual/acceptance testing around these workflows.

---

# 📊 MVP Success Criteria

The MVP is successful when the core theatre-management workflow can be demonstrated end-to-end.

### Authentication

* [ ] Users can register
* [ ] Users can log in
* [ ] Sessions persist
* [ ] Users can log out

### Productions

* [ ] Directors can create productions
* [ ] Directors can edit productions
* [ ] Directors can delete productions
* [ ] Production posters can be uploaded

### Casting

* [ ] Directors can create roles
* [ ] Directors can assign cast members
* [ ] Cast members can view assignments

### Scheduling

* [ ] Directors can create events
* [ ] Events appear in schedules
* [ ] Real-time updates work

### Conflict Prevention

* [ ] Venue overlaps are detected
* [ ] Cast overlaps are detected
* [ ] Conflicting events cannot be incorrectly saved

### Auditions

* [ ] Directors can create auditions
* [ ] Cast members can view auditions
* [ ] Cast members can sign up

### Security

* [ ] Firestore rules protect director-only resources
* [ ] Unauthorized writes are rejected

---

# 🗺️ Development Roadmap

The original project plan follows an **8-week MVP roadmap**.

| Week   | Milestone                                                              |
| ------ | ---------------------------------------------------------------------- |
| **01** | Product definition, architecture, wireframes, Flutter + Firebase setup |
| **02** | Flutter scaffold, theme, navigation and static screens                 |
| **03** | Forms, validation and state management                                 |
| **04** | Firebase Authentication and role handling                              |
| **05** | Firestore production model and CRUD                                    |
| **06** | Event scheduling, real-time updates and Storage                        |
| **07** | Casting, conflict detection, auditions and UI polish                   |
| **08** | Testing, security rules, deployment and final demo                     |

---

# 🔭 Future Scope

The MVP deliberately focuses on the most important coordination workflows.

Potential future improvements include:

### 🔔 Notifications

Push notifications for:

* Schedule changes
* New auditions
* Casting assignments
* Rehearsal updates
* Important production announcements

### 📆 Calendar Integration

Optional Google/device calendar synchronization.

### 🔎 Search & Filtering

Search productions and filter schedules by:

* Production
* Date
* Event type
* Venue
* Cast member

### 🛠️ Admin Panel

Centralized management of:

* Users
* Roles
* Permissions

### 📡 Offline Support

The broader system vision also identifies offline-first operation and synchronization as potential future reliability improvements.

---

# 🎬 Demo Flow

The recommended demo tells one continuous story rather than showing disconnected screens.

```text
1. Director logs in
        ↓
2. Opens / creates a production
        ↓
3. Adds roles
        ↓
4. Assigns cast
        ↓
5. Creates a rehearsal
        ↓
6. Attempts a conflicting venue booking
        ↓
7. StageSync detects the conflict
        ↓
8. Director resolves it
        ↓
9. Cast member opens their schedule
        ↓
10. Cast member views their assignment
        ↓
11. Cast member signs up for an audition
        ↓
12. Schedule / audition data updates
```

This demonstrates the central value of StageSync:

> **One place for the production, the people, the schedule — and the conflicts.**

---

# 📁 Repository Structure

```text
S116-0826-Team-Shiny-Flutter-StageFlow/
│
├── lib/                 # Flutter application
├── test/                # Unit and widget tests
├── assets/              # Images, icons and other assets
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

---

# 🌿 Git Workflow

We use feature branches and Pull Requests to keep development organized.

### Branch naming

```text
feature/authentication
feature/productions
feature/casting
feature/scheduling
feature/conflict-detection
feature/auditions
feature/profile

fix/schedule-validation
fix/auth-state

docs/project-readme
```

### Commit examples

```text
feat: add production creation flow
feat: add cast assignment
feat: implement venue conflict detection
feat: add audition sign-up
fix: prevent overlapping cast events
test: add conflict detection tests
docs: update project README
```

### Pull Request workflow

```text
Create Branch
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
Merge
```

Keep commits focused and avoid pushing unfinished feature work directly to `main`.

---

# 👨‍💻 Team Shiny

**Squad:** S116

| Member       | Role                               | Primary Ownership                                                                   |
| ------------ | ---------------------------------- | ----------------------------------------------------------------------------------- |
| **Kanishka** | 🎨 Frontend & UI/UX Lead           | Flutter UI, Stitch integration, reusable widgets, navigation and design system      |
| **Digvijay** | 🔥 Backend & Firebase Lead         | Authentication, Firestore, Storage, repositories, real-time data and security rules |
| **Yashraj**  | ⚙️ Features, Integration & QA Lead | Scheduling, auditions, conflict detection, integration, testing and deployment      |

### 🎨 Frontend & UI/UX

* Build StageSync screens in Flutter
* Translate designs into reusable components
* Maintain theme, typography and spacing
* Implement navigation
* Handle loading, empty, error and conflict states

### 🔥 Backend & Firebase

* Configure Firebase
* Implement Authentication
* Maintain Firestore schema
* Implement Storage
* Build repositories/services
* Maintain Security Rules and indexes

### ⚙️ Features, Integration & QA

* Implement scheduling
* Implement auditions
* Implement casting workflows
* Build venue/cast conflict detection
* Integrate frontend and backend
* Write tests
* Support deployment and demo preparation

> Ownership defines primary responsibility. Architecture, integration, reviews and testing remain collaborative team responsibilities.

---

# 📚 Project Documentation

Additional documentation should live under:

```text
docs/
├── prd/
├── ux/
├── architecture/
└── api/
```

The project documentation covers product requirements, user stories, Firebase architecture, authentication, storage, UI/UX, conflict logic, testing, roadmap and deployment.

---

# 📌 Project Status

### Current Phase

**Flutter frontend implementation → Firebase integration → MVP feature development**

### Current priorities

* [ ] Finalize Flutter application structure
* [ ] Complete StageSync UI baseline
* [ ] Implement authentication
* [ ] Implement production CRUD
* [ ] Implement roles and casting
* [ ] Implement scheduling
* [ ] Implement venue conflict detection
* [ ] Implement cast conflict detection
* [ ] Implement auditions
* [ ] Connect Firebase
* [ ] Add automated tests
* [ ] Validate Firestore Security Rules
* [ ] Prepare final demo

---

# 💡 Product Philosophy

StageSync is intentionally designed around one principle:

> ### **Reduce coordination overhead so theatre teams can focus on the production — not the paperwork.**

The application does not try to solve every theatre-management problem at once.

The MVP focuses on the workflows where coordination matters most:

```text
People
  +
Productions
  +
Roles
  +
Auditions
  +
Schedules
  +
Venues
  ↓
One coordinated system
```

---

# 🎭 Why StageSync?

Because a theatre production should not depend on someone remembering:

> “Wait… wasn't the rehearsal moved to 7?”

StageSync turns scattered production coordination into a **centralized, real-time, conflict-aware workflow**.

**Plan. Cast. Schedule. Coordinate. Perform.**

---

## 📄 Project Information

|                       |                                          |
| --------------------- | ---------------------------------------- |
| **Project**           | StageSync                                |
| **Squad**             | S116                                     |
| **Team**              | Team Shiny                               |
| **Frontend**          | Flutter / Dart                           |
| **Backend**           | Firebase                                 |
| **Database**          | Cloud Firestore                          |
| **Authentication**    | Firebase Authentication                  |
| **Storage**           | Firebase Storage                         |
| **Repository**        | `S116-0826-Team-Shiny-Flutter-StageFlow` |



---

<p align="center">
  Built with ❤️ by <strong>Team Shiny — S116</strong>
</p>

<p align="center">
  <strong>StageSync</strong> · Theatre Production Management
</p>
