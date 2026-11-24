# OS FIT V3 — Training Intelligence (Phase 1)

**A polished, English-only, offline-first personal fitness tracker for GitHub Pages.** V3 is built directly on V2. It retains the existing workout log, nutrition, body measurements, photos, training plans, cardio exercises, exercise library, readiness, muscle analytics, weekly reports, imports, cloud adapter, and backup functionality.

## Release status

**Ready for local testing / GitHub Pages deployment.** This is a **Phase 1** release. The **five Phase 1 additions work** and the remaining nine items are documented as **planned** under the in-app **Feature Roadmap**. Do **not** describe barcode camera scanning, adaptive calorie coaching, cardio distance tracking, coach login, form review, push reminders or social sharing as delivered features yet.

## What works in V3 Phase 1

1. **Advanced Autoregulation** — The Training Intelligence page compares your most recent completed working sets to your target reps and recorded RPE. It explains a conservative load suggestion and why it was made. A short history with no RPE yields *insufficient data*, not invented coaching. The user can review/edit a suggested starting load in their plan or apply it to **incomplete sets** in a live session. No previously completed sets are rewritten.
2. **Periodization Engine** — Create/edit a 4–12-week mesocycle attached to an existing plan, with a start date and target RPE. The app visualizes build / intensification / deload weeks. When you *start a planned workout* inside the cycle dates, future prescribed set counts are adjusted using a simple transparent rule, without altering completed sessions. Deload volume guidance remains optional.
3. **Exercise Substitution Engine** — Find alternatives by muscle and movement-pattern similarity with your chosen equipment (Full gym / Dumbbells + Bodyweight / Bodyweight). Swap a movement in the plan or an active session **before** completing any sets. Swapped live exercises start with an empty load to avoid carrying the previous movement's weight. A substitution log is retained.
4. **Technique & Video Library** — Browse built-in movement setup cues, execution cues and common mistakes; edit personal coaching notes; attach your own HTTPS demonstration-video URL per exercise; search for demonstrations in a separate browser tab. **No unreviewed user video is presented as an officially verified tutorial.** External videos require internet and should be judged for quality.
5. **Weekly Check-ins** — One entry per Monday-start week: sleep quality, energy, fatigue, soreness, stress, appetite, optional weight, adherence percentage and notes. The app visualizes trends and displays a **subjective, non-validated** readiness summary. The load suggestion will be more conservative when this self-report indicates fatigue.

All existing **V2** features remain accessible: **Workout Tracker, Plans, Exercise Library, Muscle Analytics, Nutrition, Body Progress, Smart Coach, Weekly Reports, Calendar, Integrations, Settings, JSON Backup**, and PWA installation.

## Start testing

1. Download the ZIP and **extract the contents** (not the ZIP itself) into a **new** GitHub repository, for example `os-fit`.
2. Open **Settings → Pages** in that repository. Choose **Deploy from a branch → `main` → `/(root)`**, then save.
3. Open your GitHub Pages URL. For your GitHub username, it is expected to be `https://omarchatg2026-afk.github.io/os-fit/` **after** successful publishing.
4. Try **Settings → Load sample data**. It supplies sample sessions, food records, a training cycle and a weekly check-in. Review **Training Intelligence**, **Technique Library** and **Weekly Check-ins**.
5. Try **Training Intelligence → Review and apply**; inspect the suggested starting weight, then start the corresponding workout from **Training Plans**. Test a substitution and save a session after checking at least one working set.
6. When finished testing, **Settings → Export JSON backup** if you want a copy, then **Erase local data** to start with your real tracking history.

For a local development server, from the extracted folder run `python3 -m http.server 8000` and open `http://localhost:8000` in a browser. The standalone HTML file included separately in the delivery is useful for a quick preview but the ZIP is better for PWA deployment.

## Data compatibility and privacy

- V3 preserves the original `mizan_fit_v1_state` local-storage key and `version: 1` snapshot shape. Existing **V1/V2 local saves and JSON backups** are still accepted, and missing V3 fields receive safe empty defaults. Nothing silently deletes the old training, meals, measurements, photos or plans.
- New V3 fields are `trainingCycles`, `activeCycleId`, `weeklyCheckins`, `exerciseGuides`, `substitutionLog` and target RPE settings. They travel with JSON backup.
- Records are **local-first**: no automatic external upload until you separately configure Supabase and choose to sign in/sync.
- **Progress photos stay on the current device**, are included in your local JSON backup, and are excluded by the included cloud adapter. Training guide URLs and check-in entries are included in cloud snapshots if you activate cloud sync.
- Backups are **not encrypted**; store them in a private location. Clearing site data can remove local records. Local browser storage is not appropriate for sensitive shared-device use without precautions.
- Do not put a secret or service-role key in any client-side file; the only acceptable frontend key is Supabase's **publishable** key.

## Optional cloud sync — requires separate setup

This package is deliberately **not connected to any Supabase project**. It must not be connected to the existing **Mizan Finance** project. If you want login/cloud sync later:

1. Create a **separate OS Fit project** in Supabase.
2. Review and run `supabase/cloud-schema.sql` in that project's SQL Editor. It creates `fit_snapshots`, enables RLS and owner-only policies, and includes `fit_pull` / `fit_push` functions with a revision guard.
3. In **Auth → URL Configuration**, set the exact OS Fit GitHub Pages URL as your Site URL and allowlisted redirect URL. Enable/verify email confirmation and delivery.
4. Edit `config.js` with that new project's URL and its `sb_publishable_...` key **only**.
5. In **Integrations**, create/sign in to a fitness-only account. Choose between the local/cloud copy deliberately, and test two-device synchronization and conflict handling before relying on it. Confirm RLS isolation between two test accounts.

The cloud adapter from V2 is preserved and can sync additional V3 fields as part of the JSON snapshot without changing its versioned SQL format, but **live Supabase login and sync have not been run against a real OS Fit project in this release**.

## Training-intelligence limitations

- The adjustment rules are **simplified training heuristics**, not a medical algorithm, personal rehabilitation advice or an individualized coaching plan. Missing or inconsistent data reduces their usefulness.
- Readiness scores are subjective and are **not** validated injury, fatigue or recovery-risk measures. Do not train through pain based on app suggestions.
- An exercise with a similar muscle/movement pattern is **not guaranteed equivalent** for every athlete. Review suitability and select reasonable loads manually.
- The periodization phases use **set-count multipliers** rather than automatically prescribing loads or complex individualized velocity profiles. Inspect each planned session.
- User-entered nutrition and exercise technique videos are not verified for accuracy.

## Folder structure

- `index.html` — layout, navigation and mobile shell
- `styles.css` — visual system, dark/light modes, responsive Training Intelligence UI
- `app.js` — all V1/V2 logic plus fully implemented Phase 1 features, registry for 14 modules and version-aware compatibility
- `cloud.js` — **optional**, unchanged revision-protected Supabase auth/sync adapter
- `config.js` — template only; no credentials included
- `sw.js`, `manifest.webmanifest`, `assets/` — PWA installation and offline caching
- `supabase/cloud-schema.sql` — optional secure snapshot-sync schema for a separate Supabase project
- `supabase/schema.sql` — older normalized reference, *not required* for the cloud adapter
- `docs/FEATURE_ROADMAP.md` — remaining phases, future module contracts and privacy requirements
- `docs/TEST_REPORT.md` — functional and responsive tests conducted

## Development status of the 14 enhancements

**Phase 1: 5/5 implemented.** **Phase 2: 0/5 implemented.** **Phase 3: 0/4 implemented.** The existing V2 food diary, simple cardio *exercises*, wearable CSV importer and body analytics are preserved; they are not the same as the additional Phase 2 advanced modules.
