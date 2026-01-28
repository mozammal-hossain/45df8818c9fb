# Design Decisions – Device Vital Monitor

This document records ambiguities, decisions, assumptions, and clarifying questions for the Device Vital Monitor take-home assignment.

---

## 1. Ambiguities Identified

### Flutter App

- **Ambiguity 1:** Should the app support dark and light themes, and how should theme preference be managed?
- **Ambiguity 2:** Should the app support multiple languages, and how should locale be determined?

### Backend

- **Ambiguity 1:** What exactly is meant by “rolling average” in the analytics endpoint? Over how many entries or what time window?
- **Ambiguity 2:** How should “missing required fields” be defined and enforced? (e.g. null vs absent in JSON, and whether 0 is valid for numerics.)
- **Ambiguity 3:** What should happen when a sensor temporarily fails or returns an unsupported value on the device?
- **Ambiguity 4:** How strict should timestamp validation be? (e.g. reject all future timestamps vs allow a small clock skew between client and server.)

---

## 2. Your Design Decisions

### Flutter App

#### Ambiguity 1: Theme Configuration (Dark/Bright Mode)

**Question:** Should the app support dark and light themes, and how should theme preference be managed?

**Options Considered:**

- Option A: Single light theme only (simple, minimal implementation)
- Option B: Both light and dark themes with system preference detection (`ThemeMode.system`)
- Option C: Light/dark themes with manual toggle and persistent user preference storage

**Decision:** Option C because:

- Modern apps are expected to support both themes for better user experience and accessibility
- Manual toggle gives users control regardless of system settings
- Persistent storage ensures user preference is remembered across app restarts
- Provides flexibility for users who prefer a specific theme even when their system theme differs

**Trade-offs:**

- Additional complexity: Requires state management for theme mode and local storage (SharedPreferences)
- More code: Need to define both `theme` and `darkTheme` in `MaterialApp`
- Slightly larger app size due to storage dependency
- However, the benefits of user control and modern UX expectations outweigh these costs

**Assumptions:**

- Users may want to override system theme preference for this monitoring app
- Dark theme is important for battery-sensitive scenarios (reducing OLED power consumption)
- Users expect theme preference to persist across app sessions
- The app should follow Material Design 3 theming best practices

**Implementation Approach:**

- Use `ColorScheme.fromSeed()` for consistent color palette generation in both themes
- Implement `ThemeMode` state management (Provider/Riverpod) for theme switching
- Store theme preference using `shared_preferences` package
- Provide theme toggle in app settings or app bar
- Default to `ThemeMode.system` on first launch, then respect user's saved preference

---

#### Ambiguity 2: Localization (Internationalization)

**Question:** Should the app support multiple languages, and how should locale be determined?

**Options Considered:**

- Option A: English only (simplest, no i18n)
- Option B: Multiple locales with device/system locale detection only
- Option C: Multiple locales with device locale + optional in-app language picker

**Decision:** Option B. Implement localization using Flutter’s built-in `flutter_localizations` and `gen-l10n` (ARB files). Use the device locale by default; no in-app language picker for now.

**Trade-offs:**

- ARB files and generated code add some complexity and build steps
- All user-facing strings must go through `AppLocalizations`
- Tests must wrap widgets in `MaterialApp` with `localizationsDelegates` and `supportedLocales` (and `ThemeProviderScope` where the UI uses it)
- Benefit: Spanish (and other locales) can be added by adding ARB files and translating keys

**Assumptions:**

- Initial locales: English (en) as default, Spanish (es) as second locale
- App follows system locale when it’s supported; otherwise falls back to en
- No requirement for persisting user-chosen locale (unlike theme)

**Implementation Approach:**

- Add `flutter_localizations` and `intl`; set `flutter.generate: true` in `pubspec.yaml`
- Add `lib/l10n/app_en.arb` (template) and `lib/l10n/app_es.arb`
- Run `flutter gen-l10n` to generate `AppLocalizations`
- Configure `MaterialApp` with `localizationsDelegates` and `supportedLocales`
- Replace hardcoded strings in `main.dart` and `DashboardScreen` with `AppLocalizations.of(context)!` lookups
- Use `l10n.yaml` to configure `arb-dir` and `template-arb-file`

---

### Backend

#### Ambiguity 1: Rolling Average Definition

**Question:** What specific window should “rolling average” use—last N logs, last hour, last day, or something else?

**Options Considered:**

- **Option A:** Rolling average over the last 100 logs (by time, most recent first). Aligns with “latest 100 entries” in the history endpoint and is easy to specify and test.
- **Option B:** Time-based window (e.g. last 1 hour, 24 hours). More intuitive for “recent” behavior but requires a fixed or configurable time window and consistent usage of `timestamp`.
- **Option C:** Global average over all stored data. Easiest to implement but does not match the usual meaning of “rolling.”

**Decision:** Option A – rolling average over the **last 100 logs** (most recent first). The brief already uses “latest 100 entries” for history, so reusing that window for analytics keeps behavior consistent and predictable.

**Trade-offs:** A device that logs very frequently will have a short effective time window; one that logs rarely will have a long one. We accept this in exchange for a simple, deterministic rule and good testability.

**Implementation:** The analytics endpoint returns averages over the most recent 100 logs only. The response includes `rolling_window_logs` (actual count used, 1–100) and `total_logs` so clients can interpret the result.

---

#### Ambiguity 2: Missing Required Fields and Range Validation

**Question:** How do we define “missing” for required fields, and how do we treat values that are present but out of range?

**Options Considered:**

- **Option A:** Treat only `null` as missing; if a value is present, validate ranges and reject when out of range. Use nullable types in the API model so absent or `null` in JSON is distinguishable from `0`.
- **Option B:** Treat both `null` and “absent” as missing via a custom model binder or separate schema validation, and keep non-nullable value types (so absent becomes default, e.g. 0).
- **Option C:** Rely on defaults and only validate ranges (e.g. reject thermal < 0 or > 3). No explicit “missing field” handling.

**Decision:** Option A – **null means missing**; if a value is present, it must be in the allowed range or the request is rejected. All required request fields are nullable in the DTO; we reject when any required field is null, and when non-null we enforce: thermal 0–3, battery 0–100, memory 0–100, timestamp not in the future.

**Trade-offs:** Slightly more verbose validation and nullable types in the API, but behavior is clear and aligns with “reject missing required fields” and “reject impossible data values” from the brief.

---

#### Ambiguity 3: Sensor Temporarily Fails or Unsupported

**Question:** What should the app/backend do when a sensor is unavailable or returns an unsupported value?

**Options Considered:**

- **Option A:** Backend only validates and stores; the app handles sensor failure (e.g. show error, skip logging, or use a sentinel). Backend does not store partial or “failed” logs.
- **Option B:** Backend accepts optional fields or a “sensor_failed” flag and stores partial records for debugging.
- **Option C:** Backend defines sentinel values (e.g. -1 for “unknown”) and accepts them as valid.

**Decision:** Option A – **backend does not store invalid or partial vitals.** If any required field is missing or out of range, the request is rejected. Handling of device-side sensor failure (retries, UI feedback, or skipping that log) is left to the app and native layers.

**Trade-offs:** Simpler backend contract and no special “unknown” semantics. The trade-off is that we do not persist failed readings for later analysis unless the product later adds an explicit “sensor error” schema.

---

#### Ambiguity 4: Timestamp Strictness and Clock Skew

**Question:** Should we reject any future timestamp, or allow a small tolerance for clock skew between device and server?

**Options Considered:**

- **Option A:** Reject strictly if `timestamp > DateTime.UtcNow`.
- **Option B:** Allow a small future skew (e.g. 5 minutes) to account for minor clock drift or timezone mistakes.
- **Option C:** Accept any timestamp and rely on “latest 100” ordering; do not validate future vs past.

**Decision:** Option B – **allow up to 5 minutes in the future** to avoid rejecting valid logs when the device clock is slightly ahead. Beyond that, we reject with “Timestamp cannot be in the future.”

**Trade-offs:** A small window could allow some misreported times, but it reduces support issues from clock skew while still blocking obviously invalid future timestamps.

---

#### Ambiguity 5: GET /api/vitals — Fixed “Latest 100” vs Pagination

**Question:** The brief says “Return historical logs (latest 100 entries).” Should the endpoint return exactly 100 items, or support pagination for a scrollable History UI?

**Options Considered:**

- **Option A:** Return exactly the latest 100 entries, no pagination. Matches the brief literally but can be slow and doesn’t suit a scrollable list (fetch all upfront).
- **Option B:** Paginated endpoint with `page` and `pageSize`; default `pageSize` 20, max 100. History screen fetches page 1 first, then loads more as the user scrolls.

**Decision:** Option B – **paginated GET /api/vitals**. Use `page` (default 1) and `pageSize` (default 20, max 100). The History screen is scrollable and uses “load more” when the user nears the bottom, instead of loading a large chunk upfront.

**Trade-offs:** Slightly more complex API and client logic, but faster initial load, better UX for long histories, and alignment with a scrollable list. The “latest 100” cap is reflected by `pageSize` max 100; clients can still request up to 100 per page if needed.

**Implementation:** Backend returns a paged envelope (`data`, `page`, `page_size`, `total_count`, `total_pages`, `has_next_page`, `has_previous_page`). Flutter uses `getHistoryPage`, `HistoryLoadMoreRequested`, and `ListView.builder` with scroll-to-load-more.

---

## 3. Assumptions Made

### Flutter App

- **Thermal API:** Android thermal state uses `PowerManager.getCurrentThermalStatus()` (API 29+) and, on API 30+, `getThermalHeadroom()` with a 10s throttle, device-limitation heuristics when status is NONE, and `OnThermalStatusChangedListener` via an EventChannel. See **ai_log.md** sections “Android ADPF Thermal API – Alignment and Gaps” and “Implementation of ‘Missing from the app’” for details.
- Users may want to override system theme preference for this monitoring app.
- Dark theme is important for battery-sensitive scenarios (reducing OLED power consumption).
- Users expect theme preference to persist across app sessions.
- Initial locales: English (en) as default, Spanish (es) as second locale; app follows system locale when supported, otherwise falls back to en.
- No requirement for persisting user-chosen locale (unlike theme).

### Backend

- **Storage and scope:** SQLite plus “latest 100” is enough for this assignment; we do not assume long-term retention or multi-tenant scale.
- **Single backend instance:** No distributed clock or multi-server considerations; UTC and in-process ordering are sufficient for “last 100” and rolling average.
- **Client honesty:** The backend trusts that `device_id`, `timestamp`, and sensor values are from the client as sent; we do not authenticate or attest device identity for this assignment.
- **Rolling window shape:** “Last 100” is by **newest-first** (most recent timestamp first), then take 100. This matches the history endpoint’s “latest 100 entries” semantics.
- **Analytics semantics:** When there are fewer than 100 logs, the rolling average uses all available logs; when there are zero, we return zeros and still expose `rolling_window_logs` (as the configured window size) for clarity.
- **GET /api/vitals:** Paginated; default `pageSize` 20, max 100. History screen uses scroll-to-load-more rather than fetching a large fixed set upfront.

---

## 4. Questions You Would Ask

### Flutter App

- “Should the app support RTL locales, and do we need to handle layout mirroring?”
- “Is theme persistence required for the first release, or is system-only theme acceptable initially?”
- “Which locales are in scope for launch—en only, or en + one or two others?”

### Backend

1. **Rolling average:** “Should ‘rolling’ be by count (e.g. last 100 logs) or by time (e.g. last 24 hours)? What time window or count do you want for the dashboard?”
2. **Sensor failure:** “When a sensor fails on the device, should we still send a log (e.g. with a special ‘unavailable’ value or a flag), or skip that sample? Do we need to track failure rates in the backend?”
3. **Identifiers and privacy:** “Is `device_id` meant to be a stable device identifier, and do we need to consider PII or retention rules for it?”
4. **Multiple devices per user:** “Will one user have many devices, and do we need per-device analytics or only global/aggregate?”
5. **Timestamp meaning:** “Should `timestamp` always be in UTC, and should we reject requests that are ‘too old’ (e.g. older than 24 hours) to avoid backfilled or test data polluting analytics?”

These would help decide whether the current “last 100 logs,” null-as-missing, and no partial logs are the right product trade-offs or if they should be adjusted.
