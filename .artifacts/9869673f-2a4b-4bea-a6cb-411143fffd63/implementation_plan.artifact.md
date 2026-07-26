# Implementation Plan - iOS Compatibility and Codemagic Readiness

This plan outlines the steps to make the `zen_mart_pro` Flutter project fully compatible with iOS 15.0 and production-ready for Codemagic, while preserving all existing Android functionality and Dart business logic.

## User Review Required

> [!IMPORTANT]
> A `GoogleService-Info.plist` file is missing for the iOS target. While I can configure the project to expect it, you will need to download the official file from the Firebase Console and place it in the `ios/Runner` directory for Firebase to function on iOS.

> [!NOTE]
> I will be adding necessary permissions to `Info.plist` for plugins like `image_picker` and `google_sign_in` to ensure they don't crash on iOS.

## Proposed Changes

### iOS Configuration

#### [NEW] [Podfile](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Podfile)
- Create a production-ready `Podfile`.
- Set `platform :ios, '15.0'`.
- Add post-install hooks to ensure all plugin targets also use iOS 15.0 and have `ENABLE_BITCODE` disabled.

#### [MODIFY] [project.pbxproj](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Runner.xcodeproj/project.pbxproj)
- Update `IPHONEOS_DEPLOYMENT_TARGET` from `13.0` to `15.0` across all build configurations (Debug, Release, Profile).
- Ensure `ENABLE_USER_SCRIPT_SANDBOXING` is set to `NO` to avoid common Xcode 15+ build issues.

#### [MODIFY] [Info.plist](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Runner/Info.plist)
- Add `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, and `NSMicrophoneUsageDescription` for `image_picker`.
- Add `CFBundleURLTypes` for `google_sign_in`.
- Add Firebase Messaging background mode permissions.

#### [MODIFY] [AppDelegate.swift](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Runner/AppDelegate.swift)
- Ensure Firebase is properly initialized if needed (though standard Flutter plugins usually handle this, a check is good).

### CI/CD Configuration

#### [MODIFY] [codemagic.yaml](file:///C:/Users/Husnain/Desktop/zen_mart_pro/codemagic.yaml)
- Populate with a complete production workflow for both Android (APK/AAB) and iOS (IPA).
- Configure build steps, environment variables, and artifact publishing.

## Verification Plan

### Automated Tests
- `flutter analyze` to ensure no Dart-side breakages.
- Verify file existence and content for `Podfile` and `codemagic.yaml`.

### Manual Verification
- The user should attempt an iOS build using `flutter build ios --no-codesign` (locally) or via Codemagic to verify the configuration.
- The user must provide the `GoogleService-Info.plist` file.
