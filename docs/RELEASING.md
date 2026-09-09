# Releasing Reye

`pubspec.yaml` is the source of truth for the version. Reye uses semantic versions and an Android build number:

```yaml
version: 1.0.0+1
```

Use a new semantic version for each GitHub Release and always increase the build number for Android. Add the same version to `CHANGELOG.md` before building.

## Preflight

```powershell
powershell -ExecutionPolicy Bypass -File tool/release/check_release.ps1
flutter pub get
flutter analyze
flutter test
```

## Android APK

Create a long-lived release keystore once. Keep it outside the repository and back it up securely:

```powershell
keytool -genkeypair -v -keystore C:\secure\reye-release.jks -alias reye-release -keyalg RSA -keysize 2048 -validity 10000
```

Copy `android/key.properties.example` to `android/key.properties`, then enter the real path, alias, and passwords. Never commit either the keystore or `key.properties`.

Build and package the signed APK:

```powershell
flutter build apk --release
powershell -ExecutionPolicy Bypass -File tool/release/package_android.ps1
```

The GitHub assets are written to `dist/`:

- `Reye-Android-vX.Y.Z.apk`
- `Reye-Android-vX.Y.Z.apk.sha256`

Keep using the same keystore for every update. Android will reject an update signed with a different key.

## Windows

Build and package the portable release:

```powershell
flutter build windows --release
powershell -ExecutionPolicy Bypass -File tool/release/package_windows.ps1 -SkipInstaller
```

To also create an installer, install Inno Setup 6 and omit `-SkipInstaller`:

```powershell
powershell -ExecutionPolicy Bypass -File tool/release/package_windows.ps1
```

Generated GitHub assets:

- `Reye-Windows-x64-Portable-vX.Y.Z.zip`
- `Reye-Windows-x64-Setup-vX.Y.Z.exe`
- A `.sha256` file for each artifact

Windows code signing is optional but reduces SmartScreen warnings. With a code-signing certificate installed in the Windows certificate store, set `REYE_WINDOWS_CERT_THUMBPRINT` before packaging. The script signs `Reye.exe` and the installer and verifies both signatures.

## Publish

Review the generated files, commit the release changes, tag that commit with the version from `pubspec.yaml`, and attach every file under `dist/` to the matching GitHub Release.

Example tag:

```powershell
git tag -a v1.0.0 -m "Reye 1.0.0"
git push origin v1.0.0
```
