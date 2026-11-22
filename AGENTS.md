# SITCON App

- This repository must build without a backend checkout. Keep the Dart offline engine in `packages/sitcon_backend/`; the TypeScript API and admin dashboard belong in `2027-game`.
- Install the pinned Flutter and Java toolchains with `mise install` from the repository root. Run Flutter commands through `mise exec --`.
- Follow the existing MVVM structure: views in `lib/views/`, view models in `lib/viewmodels/`, and adapters grouped by concern in `lib/services/`. The HTTP and offline gameplay adapters share the `GameService` contract. Do not silently fall back to offline data when the server is unavailable.
- Use Material 3 Expressive and the existing navigation.
- Add user-visible strings to `lib/l10n/app_en.arb` first, including `@key` placeholder metadata where needed, then update matching keys and placeholders in `app_zh.arb` and `app_zh_TW.arb`. Use `context.l10n` from `localization.dart` for UI strings and `gameText` for game/API message codes. Run `mise exec -- flutter gen-l10n`; include the regenerated `app_localizations*.dart` files and never edit them by hand.
- The scanner uses NTAG. Android starts listening when its route becomes active; iOS opens one system NFC sheet per tap. Verify native NFC on a physical device; simulator results are not NFC validation.
- Run `mise exec -- flutter analyze` and the affected `mise exec -- flutter test` targets. Use `.env.example` and the existing VS Code launch profiles for environment changes; never commit a filled `.env` or credentials.
