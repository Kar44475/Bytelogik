# bytelogik

A Flutter project.

## Platform support

- Supported: Android, iOS, and Web (Chrome browser). The code now uses Drift database for local persistence and works across all platforms.
- Tested: Android and Chrome web browser. The app has been tested and works on both mobile and web platforms.

## Development environment (reported by `flutter doctor -v`)

- Flutter: 3.32.0 (stable)
- Dart: 3.8.0
- Android SDK: 34.0.0 (platform android-35, build-tools 34.0.0)
- Java: OpenJDK 21.0.3 (bundled with Android Studio)

## Local storage

- This project now uses **Drift database** (SQLite) for local persistence of user data.
- **Cross-platform support**: Works on Android, iOS, and Chrome web browser.
- **Web support**: Uses IndexedDB with SQLite WASM for web browsers.

## Web Browser Notes

- The app may show informational messages about browser feature support
- These are normal and don't affect functionality
- Drift automatically uses the best available implementation for each browser


### Android native requirements

- The Android native sqflite plugin may require a specific NDK version. This project sets `ndkVersion = "27.0.12077973"` in `android/app/build.gradle.kts` to satisfy native build requirements for some environments.



