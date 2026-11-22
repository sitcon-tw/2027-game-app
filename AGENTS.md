# SITCON App

- This repository must build without a backend checkout. Keep the Dart offline engine in `packages/sitcon_backend/`; the TypeScript API and admin dashboard belong in `2027-game`.
- Install the pinned Flutter and Java toolchains with `mise install` from the repository root. Run Flutter commands through `mise exec --`.
- Follow the existing MVVM structure: views in `lib/views/`, view models in `lib/viewmodels/`, and adapters grouped by concern in `lib/services/`. The HTTP and offline gameplay adapters share the `GameService` contract. Do not silently fall back to offline data when the server is unavailable.
- Use Material 3 Expressive and the existing navigation. Put user-visible text in the ARB catalogs under `lib/l10n/`; regenerate with `mise exec -- flutter gen-l10n`.
- The scanner uses NTAG and starts when its route becomes active. Verify NFC or platform integration changes on a physical device; simulator results are not NFC validation.
- Run `mise exec -- flutter analyze` and the affected `mise exec -- flutter test` targets. Use `.env.example` and the existing VS Code launch profiles for environment changes; never commit a filled `.env` or credentials.
