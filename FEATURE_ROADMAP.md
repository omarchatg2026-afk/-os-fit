# OS Fit V3 — Feature Roadmap and Implementation Contracts

This document mirrors the **14-feature in-app roadmap**. Phase 1 is implemented; Phase 2 and 3 remain planned (not hidden or falsely advertised as active).

## Phase 1 — LIVE

| # | Module | Data model | UI |
|---|---|---|---|
| 1 | Autoregulation | Derived from `sessions`, `settings.targetRPE`, `plans[].days[].items[].startWeight` and weekly check-ins | Training Intelligence, live workout |
| 2 | Periodization | `trainingCycles[]`, `activeCycleId` | Training Intelligence; future plan sessions |
| 3 | Substitution | `substitutionLog[]`, existing `exerciseId` in plans/live session | Training Plans, Workout Tracker, Technique Library |
| 4 | Technique / video | `exerciseGuides` map of exercise ID to notes and an HTTPS URL | Technique Library, modal |
| 5 | Weekly check-ins | `weeklyCheckins[]` (Monday week key, self-rating fields, notes) | Weekly Check-ins, Training Intelligence |

## Phase 2 — PLANNED

| # | Module | Suggested storage contracts | External requirements |
|---|---|---|---|
| 6 | Dynamic calorie targets | `energyTrend[]`, `nutritionRecommendations[]` with evidence windows and explicit approval status | Enough weight & consistently logged intake; review UI |
| 7 | Barcode food lookup | `foodProductCache[]` with GTIN, data provider, label serving size and verification date | Authorized nutrition API/permission, camera `BarcodeDetector` fallback, clear consent |
| 8 | Cardio & conditioning | `cardioSessions[]`: modality, date, duration, distance, self-reported intensity, optional HR | Device permissions for sensors/routes, no fabricated pace or HR |
| 9 | Strength standards | `strengthBaselines[]` and cited external reference version | Reliable comparison cohorts or opt-in private historic baseline |
| 10 | Habits & lifestyle | `habitDefinitions[]`, `habitLogs[]`, user preferences | Optional scheduled entries/notifications |

## Phase 3 — PLANNED

| # | Module | Suggested storage contracts | Security & integration requirements |
|---|---|---|---|
| 11 | Coach collaboration | `coachConnections[]`, per-athlete grants, history of access and approvals | Supabase auth, permissioned RLS tables, revocable consent; never expose all athlete records |
| 12 | Video form review | `formReviewRequests[]`, video metadata and feedback | **Private** storage, signed URLs, upload limits, retention and deletion policy |
| 13 | Smart reminders | `reminderRules[]` with opt-in and timezone | Web Notification permission / native scheduling; local fallback |
| 14 | Challenges & sharing | `sharedWorkouts[]`, challenge memberships, visibility settings | Explicit opt-in per share, no default public body or health data |

## Integration architecture

V3 keeps the V2 **local-first single-snapshot format**. Phase 1 fields are optional and normalized upon load, so an older JSON file is still accepted. Future phases should likewise start with optional fields and a migration layer. If coach collaboration and video uploads are implemented, avoid extending the snapshot to share data between users: use **dedicated normalized relational tables, owner/coach RLS policies, private storage and server-verified permission grants**. Never trust browser-supplied user IDs for grants. The current snapshot sync is personal-user-only.

Feature flag/status lives in `V3_FEATURES` in `app.js` and is exposed through `window.MizanFit.trainingIntelligence.featureRegistry()` for testing. It is intentionally honest: only Phase 1 entries have status `live`. The roadmap UI never displays installable or functional controls for services that do not exist.

## Minimum acceptance criteria before advancing

- **Phase 2:** Verify nutrition units and serving sizes, handle absent data, local-first CSV import, backup/restore, provider outage, accessibility and error fallbacks.
- **Phase 3:** Verify account isolation, coach invitation/revocation, privacy defaults, private video storage, deletion flow, conflict behavior, permission audits, data minimization and reports of abuse.
- **Every release:** Run browser responsiveness and functional end-to-end tests. Do not assume real-world Supabase connectivity from simulated sync tests.
