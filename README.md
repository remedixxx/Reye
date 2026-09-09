# Reye

[فارسی](README_FA.md) | English

Reye is a calm, open-source screen-break reminder for Windows and Android. It helps you build a regular break habit with configurable, timestamp-based focus cycles inspired by the 20-20-20 rule.

Reye works fully offline. It has no accounts, ads, analytics, tracking, backend, or personal-data collection. It is a reminder tool, not a medical treatment.

## Download

### [Download the latest Reye release](../../releases/latest)

GitHub Releases is the only official download source. Choose the file for your platform:

| Platform | File | Use |
| --- | --- | --- |
| Windows 10/11 x64 | `Reye-Windows-x64-Setup-vX.Y.Z.exe` | Recommended installer |
| Windows 10/11 x64 | `Reye-Windows-x64-Portable-vX.Y.Z.zip` | Portable version; no installation |
| Android 7.0+ | `Reye-Android-vX.Y.Z.apk` | Direct Android installation |

Each download has a matching `.sha256` file. Release binaries are attached to GitHub Releases and are intentionally not committed to the source repository.

## Install

### Windows installer

1. Open the [latest release](../../releases/latest).
2. Download `Reye-Windows-x64-Setup-vX.Y.Z.exe` and its `.sha256` file.
3. Run the installer and follow the prompts. It installs for the current user and does not require administrator access.
4. Launch Reye from the Start menu or desktop shortcut.

The Windows build may show an **Unknown publisher** or SmartScreen warning because public builds are not currently signed with a paid Authenticode certificate. Continue only when the file came from this repository's official release page and its checksum matches.

### Windows portable

1. Download `Reye-Windows-x64-Portable-vX.Y.Z.zip`.
2. Extract the entire ZIP to a folder.
3. Run `Reye.exe` from that folder.

Do not copy only `Reye.exe`; the DLLs and `data` directory beside it are required.

### Android

1. Open the [latest release](../../releases/latest) on the Android device.
2. Download `Reye-Android-vX.Y.Z.apk`.
3. Allow **Install unknown apps** for the browser or file manager used to open the APK, when Android asks.
4. Install and open Reye.
5. Allow notifications so background reminders and the ongoing countdown can work.

You can disable the browser's **Install unknown apps** permission after installation. Future versions signed with the same Reye release key can update the installed app without removing its local settings.

### Verify a download on Windows

Run PowerShell in the download directory:

```powershell
Get-ChildItem .\Reye-* -File | Where-Object Extension -ne '.sha256' | Get-FileHash -Algorithm SHA256
Get-Content .\*.sha256
```

Compare the hash for the downloaded package with the value in its matching `.sha256` file on the release page. Do not install a file when the hashes differ.

## Features

- Configurable focus interval, final countdown visibility, and break duration
- Reliable timestamp-based timer that recovers after app restarts
- Start, pause, reset, five-minute snooze, and complete exit controls
- English and Persian interface
- System, light, and dark themes
- Local settings and timer persistence
- Windows corner countdown, always-on-top reminder, system tray, and launch at startup
- Android ongoing countdown notification and break notification
- Optional Android full-screen reminder and pause-while-screen-off behavior
- No Android floating-overlay permission, exact-alarm permission, foreground service, or Windows notification plugin

## How it works

The default cycle is simple:

1. Reye starts a 20-minute focus interval.
2. The timer runs quietly without keeping a large countdown on screen.
3. During the final 20 seconds, a compact countdown appears on Windows or updates in the Android notification.
4. At zero, Reye shows a calm reminder to look at something far away for 20 seconds.
5. Confirm the break to begin a new cycle, or snooze it for five minutes.

All durations can be changed in Settings. Timer calculations use stored timestamps rather than depending on a Dart timer continuously running in the background.

## Platform behavior

### Windows

- The main window changes into a small, draggable corner countdown near the end of a cycle.
- The countdown and reminder stay on top while visible.
- The corner position and reminder presentation can be configured.
- Minimizing Reye sends it to the Windows notification area.
- Only one Reye instance can run at a time.
- Windows reminders use the Flutter window; native Windows notifications are intentionally not included.

### Android

- An ongoing notification displays the remaining time while a cycle is active.
- Android 13 and newer requests notification permission. Reye still shows reminders while open if permission is denied.
- The optional **Open reminder screen** setting uses Android's full-screen notification mechanism.
- Android 14 and newer may require additional full-screen intent permission from system settings.
- The optional **Pause while screen is off** setting excludes screen-off time from the focus cycle.
- Reye does not request `SYSTEM_ALERT_WINDOW` or exact-alarm permission.

Android and device-vendor battery policies can delay background reminders. Full-screen reminder launches are also controlled by Android and are not guaranteed on every device, so a high-priority notification remains the fallback.

## Privacy and permissions

Reye stores settings and timer state locally using `shared_preferences`. It does not collect or transmit personal information. See the bilingual [Privacy Policy](PRIVACY.md).

Android permissions are used only for app features:

- Notifications: ongoing timer and break reminders
- Full-screen intent: optional reminder screen when a break becomes due

Windows launch-at-startup is opt-in. No platform permission is used for advertising, tracking, or data collection.

## Supported platforms

- Windows 10 or 11, x64
- Android 7.0 or newer (`API 24+`)

iOS, macOS, Linux, and web are intentionally unsupported.

## Build from source

### Requirements

- Flutter stable with Dart `>=3.12.0 <4.0.0`
- Visual Studio with **Desktop development with C++** for Windows builds
- Android SDK and JDK 17 for Android builds
- Git

Clone the repository, then validate it:

```bash
flutter pub get
flutter analyze
flutter test
```

Run on Windows:

```bash
flutter run -d windows
```

Run on Android:

```bash
flutter run -d android
```

Build release binaries:

```bash
flutter build apk --release
flutter build windows --release
```

Android release builds require your own signing key and `android/key.properties`. Start from `android/key.properties.example`; never commit the real properties file or keystore. The permanent Android application ID is `com.reye.app`.

See [docs/RELEASING.md](docs/RELEASING.md) for signing, packaging, checksums, installer generation, artifact naming, and the complete GitHub release procedure.

## Project structure

The shared Flutter code contains the timer domain model, Riverpod controllers, persistence, localization, theme, and UI. Platform-specific behavior is isolated behind services:

- `lib/android/`: Android notification, alarm, screen-state, and permission adapters
- `lib/windows/`: Windows window, tray, startup, and single-instance adapters
- `android/`: minimal Kotlin channels for Android system integration
- `windows/`: native Windows runner configuration
- `test/`: timer calculations, state transitions, settings validation, snooze, and recovery tests

## Contributing

Issues, fixes, translations, accessibility improvements, and focused feature proposals are welcome.

1. Check the [existing issues](../../issues) before opening a duplicate.
2. Fork the repository and create a focused branch.
3. Keep platform code isolated and preserve Windows and Android behavior.
4. Run `flutter analyze` and `flutter test`.
5. Open a pull request describing the behavior change and how it was verified.

Do not add advertising, tracking, personal-data collection, or unnecessary online services.

## Versioning and releases

Reye follows semantic versions in `pubspec.yaml` using `major.minor.patch+build`, for example `1.0.0+1`. Each public release should have a matching Git tag such as `v1.0.0` and a documented entry in [CHANGELOG.md](CHANGELOG.md).

The current Flutter toolchain may warn that `shared_preferences_android` still applies the legacy Kotlin Gradle Plugin. This is an upstream migration warning and does not invalidate a successful build. Built-in Kotlin should be enabled only after every Android plugin in the dependency graph supports it.

## Known limitations

- The Windows countdown reuses the main Flutter window instead of opening a second independent window.
- Unsigned Windows releases can trigger a SmartScreen warning.
- Android background timing is subject to operating-system and device-vendor battery policies.
- Android full-screen reminders may fall back to a notification because the operating system controls background launches.

## License

Reye source code is available under the [MIT License](LICENSE). Vazirmatn is distributed under the SIL Open Font License 1.1; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
