# Design Decisions

## Ambiguity 1: Theme Configuration (Dark/Bright Mode)

**Question:** Should the app support dark and light themes, and how should theme preference be managed?

**Options Considered:**
- Option A: Single light theme only (simple, minimal implementation)
- Option B: Both light and dark themes with system preference detection (`ThemeMode.system`)
- Option C: Light/dark themes with manual toggle and persistent user preference storage

**Decision:** I chose Option C because:
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

## Ambiguity 2: Localization (Internationalization)

**Question:** Should the app support multiple languages, and how should locale be
determined?

**Options Considered:**
- Option A: English only (simplest, no i18n)
- Option B: Multiple locales with device/system locale detection only
- Option C: Multiple locales with device locale + optional in-app language picker

**Decision:** Option B. Implement localization using Flutter’s built-in
`flutter_localizations` and `gen-l10n` (ARB files). Use the device locale by
default; no in-app language picker for now.

**Trade-offs:**
- ARB files and generated code add some complexity and build steps
- All user-facing strings must go through `AppLocalizations`
- Tests must wrap widgets in `MaterialApp` with `localizationsDelegates` and
  `supportedLocales` (and `ThemeProviderScope` where the UI uses it)
- Benefit: Spanish (and other locales) can be added by adding ARB files and
  translating keys

**Assumptions:**
- Initial locales: English (en) as default, Spanish (es) as second locale
- App follows system locale when it’s supported; otherwise falls back to en
- No requirement for persisting user-chosen locale (unlike theme)

**Implementation Approach:**
- Add `flutter_localizations` and `intl`; set `flutter.generate: true` in
  `pubspec.yaml`
- Add `lib/l10n/app_en.arb` (template) and `lib/l10n/app_es.arb`
- Run `flutter gen-l10n` to generate `AppLocalizations`
- Configure `MaterialApp` with `localizationsDelegates` and `supportedLocales`
- Replace hardcoded strings in `main.dart` and `DashboardScreen` with
  `AppLocalizations.of(context)!` lookups
- Use `l10n.yaml` to configure `arb-dir` and `template-arb-file`
