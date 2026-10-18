# Noor Enterprise — Android MVP v1.0

This is a starter Flutter source project for an offline-first product catalogue, order entry, stock, and target/report prototype.

## Important limitations
- This starter stores data locally on one device using SharedPreferences. It does NOT sync between phones yet.
- Demo credentials are hard-coded and are NOT secure. Do not use this app for real customer or business data until real authentication, access rules, backups, and cloud sync are added.
- The demo treats approved order totals as sales; it is not a full accounting system.
- Product images are copied into the app's private documents folder.
- Demo products are inserted on a fresh install.

## Demo login
- Admin: `admin` / `admin123`
- Dealer: `dealer` / `dealer123`

## Build from an Android phone (Termux route)
Building Flutter Android APK directly in Termux can be difficult and may fail due to Android SDK/Gradle compatibility. The most reliable free route from a phone is a browser-based cloud development environment, such as GitHub Codespaces (availability/quotas depend on your account). If you already use Termux, it can still be used to edit files, but a working Flutter + Android SDK setup is required.

### Browser/cloud route
1. Create or sign in to a GitHub account.
2. Create a new repository named `noor-enterprise`.
3. Upload `pubspec.yaml` and the `lib/` folder from this project.
4. Open the repository in a cloud development environment that supports Flutter and Android SDK. Free quotas and access may vary; do not assume unlimited free builds.
5. Run:
   ```bash
   flutter pub get
   flutter analyze
   flutter build apk --debug
   ```
6. The debug APK should be created at:
   `build/app/outputs/flutter-apk/app-debug.apk`
7. Download the APK to your Android phone and install it. Android may ask you to allow installing unknown apps for the browser/file manager you used.

## If you have a Flutter environment already
Run from the project root:
```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

## Planned next stage: cloud sync
For genuine online/offline sync across Admin and Dealer devices:
1. Add Firebase Authentication (separate accounts and roles).
2. Add Firestore as the cloud source of truth.
3. Add security rules so Dealers cannot edit products or stock.
4. Add a local database/outbox and conflict resolution for offline changes.
5. Add backups, audit logs, and exportable reports.

## Project structure
- `pubspec.yaml` — Flutter dependencies
- `lib/main.dart` — MVP app source


## Easier phone-only build option with GitHub Actions
This project includes `.github/workflows/build-apk.yml`.
1. Upload the project files to a GitHub repository with the same folder structure (including `.github/workflows/build-apk.yml`).
2. Open the repository's **Actions** tab and select **Build Noor Enterprise APK**.
3. Tap **Run workflow** if it has not started automatically.
4. Wait for the workflow. If it fails, open the log and check the first failing step.
5. On a successful run, open that run, scroll to **Artifacts**, and download `noor-enterprise-debug-apk`.
6. Extract the downloaded artifact ZIP and install `app-debug.apk` on your Android phone.

GitHub Actions has usage limits and may ask you to enable Actions. This is not a guaranteed unlimited-free build service. The workflow has not been run or verified in this chat.
