# Implementation Plan - Restore Official Flutter iOS Configuration

Restore the `ios` folder to the official Flutter template to ensure compatibility with modern Flutter versions (3.35+) and Codemagic, while maintaining the project's specific requirements (iOS 15.0, Firebase).

## User Review Required

> [!IMPORTANT]
> I will be removing the custom `Podfile` and manual `Generated.xcconfig` files I created previously. These will be replaced by the official Flutter templates. This ensures that Codemagic can correctly build the project without encountering missing deprecated files like `xcode_backend.rb`.

## Proposed Changes

### iOS Configuration Restoration

#### [DELETE] [Podfile](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Podfile)
- Remove the current "hacked" Podfile.

#### [DELETE] [Generated.xcconfig](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Flutter/Generated.xcconfig)
- Remove the hardcoded environment file to allow the Flutter SDK to regenerate it correctly.

#### [DELETE] [flutter_export_environment.sh](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Flutter/flutter_export_environment.sh)
- Remove the manual script to allow the Flutter SDK to regenerate it correctly.

#### [NEW] [Podfile](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Podfile)
- Use `flutter create` to regenerate the official template.
- Update `platform :ios, '15.0'` at the top.

#### [MODIFY] [project.pbxproj](file:///C:/Users/Husnain/Desktop/zen_mart_pro/ios/Runner.xcodeproj/project.pbxproj)
- Double-check and ensure `IPHONEOS_DEPLOYMENT_TARGET` is consistently `15.0`.

### Preservation of Features
- **Firebase**: Ensure `GoogleService-Info.plist` remains in `ios/Runner`.
- **Permissions**: Ensure `Info.plist` keeps the necessary privacy usage descriptions (Camera, Photo Library, etc.).

## Verification Plan

### Automated Tests
- `flutter pub get`: Should regenerate all local configuration files correctly.
- `flutter analyze`: Should pass without issues.

### Manual Verification
- Verify that `Podfile` now uses `require ... podhelper` instead of `xcode_backend.rb`.
- Verify that no hardcoded paths (like `C:\Users\...`) exist in the project files (excluding local-only files like `Generated.xcconfig` which are ignored by Git).
