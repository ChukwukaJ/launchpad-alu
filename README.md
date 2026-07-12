# LaunchPad ALU

A Flutter + Firebase mobile application connecting ALU students seeking internship
experience with student-led startups and early-stage ventures within the ALU
ecosystem.

## Core features

- Email/password auth with two account types: **Student** and **Startup**
- Startup registration + **ALU admin verification workflow** (unverified
  startups cannot post publicly)
- Opportunity posting, real-time discovery feed, search & filtering
- Skill-based match scoring (transparent, explainable — not a black box)
- Application submission and a five-stage status pipeline
  (Submitted → Under Review → Interview → Accepted/Rejected)
- Real-time notifications on new applications and status changes
- Bookmarking / saved opportunities
- Startup-side analytics dashboard (applicant funnel, open postings, etc.)

## Architecture

```
lib/
  core/            theme, constants
  data/
    models/        plain Dart data classes (fromMap/toMap, no Firebase leakage)
    repositories/   ONLY layer that talks to Firebase SDKs
  cubits/          state management (flutter_bloc's Cubit) — one per feature
  screens/         UI, organized by student / startup / auth / shared
  widgets/         shared UI components
```

**State management: Cubit** (`flutter_bloc` package). Each feature area
(auth, startup, opportunity, application, bookmark, search) has its own
Cubit + immutable State class. Screens use `BlocBuilder`/`BlocConsumer` to
react to state and never call Firebase directly — they call Cubit methods,
which call Repository methods.

**Why Cubit over raw setState or a global store:** state changes need to
propagate across independently-scrolling screens (e.g. applying on the
detail screen must update the tracker tab and the applicant count on the
startup's dashboard, live, without either screen polling). Cubit lets each
screen subscribe only to the slice of state it cares about, and Firestore's
own real-time listeners (wrapped inside the repositories) are what actually
push the updates — Cubit's job is just to relay repository streams into
widget-consumable state.

**Why a repository layer:** Cubits are tested and reasoned about without a
live Firebase project (repositories are constructor-injected, so tests pass
in fakes/mocks). It also means swapping Firestore for another backend later
touches only `data/repositories/`, not the 20+ screens that consume it.

## Firestore schema

| Collection | Key fields | Notes |
|---|---|---|
| `users/{uid}` | email, fullName, role, skills[], onboardingComplete | role ∈ {student, startup, admin} |
| `users/{uid}/bookmarks/{opportunityId}` | savedAt | private subcollection |
| `startups/{id}` | ownerUid, name, status, industry | status ∈ {pending, verified, rejected} |
| `opportunities/{id}` | startupId, title, category, requiredSkills[], status | status ∈ {open, closed} |
| `applications/{id}` | opportunityId, studentUid, startupId, status | status pipeline, see above |
| `notifications/{id}` | recipientUid, type, read | fan-out written via batched writes alongside the triggering action |

Security rules (`firestore.rules`) enforce all ownership and role
boundaries server-side — see the comment block at the top of that file for
the full trust model. In particular, opportunities can only be *created* by
a startup whose own `status` field is `verified`, checked via a `get()`
lookup inside the rule, not just hidden in the UI.

## Setup

1. `flutter pub get`
2. Install the FlutterFire CLI and connect your own Firebase project:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This overwrites the placeholder `lib/firebase_options.dart` with your
   real project credentials.
3. In the Firebase Console, enable **Authentication → Email/Password**,
   create a **Firestore** database (start in production mode), and deploy
   `firestore.rules`:
   ```
   firebase deploy --only firestore:rules
   ```
4. To test the admin verification flow, manually set one user document's
   `role` field to `"admin"` in the Firestore console, then open
   `AdminVerificationScreen` (wire a route to it, or launch it directly
   during grading/demo).
5. `flutter run`

## Known limitations / future improvements

- Chat/messaging between student and startup is not implemented — cover
  notes are one-way; a natural next step is a `conversations` subcollection
  per application.
- Match scoring is a simple skill-overlap ratio; a future version could
  weight skills by recency/proficiency or incorporate application outcomes.
- No automated CI pipeline is included; `flutter test` covers Cubit logic
  with `bloc_test` + `mocktail`-based repository fakes but there is no CD.
- Firebase Cloud Messaging is wired for push notification permissions but
  the Cloud Function that would send a push on new Firestore documents is
  not included — in-app real-time notifications work without it.
