# Penguin Search — milestone 1

A Flutter/Dart source starter for Samir and the Penguin Search team.
This is a local, memory-only development demo, not a finished university service.
No authentication, ID verification, backend, or production access control exists yet.
Never deploy this demo as the campus app or enter real IDs into it.

## Start on Windows (Chrome first)

1. Install Flutter stable using https://docs.flutter.dev/install/quick . Install the Flutter extension in VS Code (it also installs Dart support). Restart VS Code after changing PATH.
2. Extract this ZIP. Open the `penguin_search` folder in VS Code; `pubspec.yaml` must be visible at its root.
3. Open Terminal > New Terminal. Run:

```powershell
flutter --version
flutter doctor -v
flutter create --platforms=web,android --project-name penguin_search .
flutter pub get
```

The create command generates the web/Android runner files omitted from this source starter. Do not use `--overwrite`. Keep our existing lib, pubspec.yaml, and tests. If it generates `test/widget_test.dart` (the default counter-app test), remove that template test only; retain `report_store_test.dart` and `demo_test.dart`.

```powershell
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

If Chrome is unavailable on Windows, try `flutter run -d edge`.
Android SDK warnings do not prevent the browser milestone. To run on Android later, install/configure Android Studio's SDK and an emulator or USB-debugging device, follow `flutter doctor`, then select it using `flutter devices` / `flutter run -d DEVICE_ID`.

## What to try

- Open the explicitly labeled local demo.
- Search for bottle, filter by Found, and open its details.
- Mark the sample bottle returned, confirm the handoff, and see it disappear from Items and appear in History.
- Open the headphones listing: it belongs to a different sample user, so there is no return button.
- Submit an empty report to see required-field messages.
- Add a lost/found report with a test JPG/PNG, name, description, location, category, and date.
- Resize the browser to phone width and laptop width.
- Restart: reports reset. Durable storage is NOT implemented yet.

## File guide

- `lib/main.dart`: theme, demo entry, responsive feed, filters, details, report form.
- `lib/report.dart`: report model and replaceable in-memory store.
- `test/report_store_test.dart`: archive/history, permission guard, validation, search.
- `test/demo_test.dart`: entry screen and navigation smoke test.
- `docs/REQUIREMENTS.md`: requirement coverage and pending decisions.

Photos use Flutter's image_picker package. The initial UI selects existing photos, including photos previously taken on a phone. Direct camera capture and Android interrupted-picker recovery remain mobile tasks.

## iOS later

On a Mac with Xcode configured, generate the iOS runner with `flutter create --platforms=ios .`. Before using the photo picker, add `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist` explaining that item photos are attached to reports. If we add direct camera capture, add `NSCameraUsageDescription` too. Complete signing and run on an iOS simulator/device. Do not claim iOS compatibility verified until tested there.

## Verification status

The source and ZIP were inspected and the ZIP integrity checked. Flutter and Dart were unavailable in the authoring environment, so compilation, analysis, tests, and visual execution have NOT been run. The included tests are ready for your installed Flutter toolchain. Send the full first error if a command fails; do not skip it.

## Next milestone

Choose/configure backend authentication, database, and private image storage. Enforce allowed university accounts and verification on the SERVER before returning any listings or allowing writes. A client-side email check or uploaded ID image is not identity verification. No secrets belong in source control.

Then connect durable reports, server authorization, and claim participants before adding the remaining social features and administrator workflows. See the checklist for all outstanding work.
