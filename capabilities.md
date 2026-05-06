# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Camera: Required for barcode scanning and receipt OCR
- Photo Library: Required for receipt photo import
- Notifications: Required for expiration alerts
- iCloud (CloudKit): Required for family sharing and multi-device sync
- In-App Purchase: Required for subscription monetization

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications | Configured | Xcode project settings |
| iCloud (CloudKit) | Configured | Xcode project settings |
| In-App Purchase | Configured | Xcode project settings |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| Camera (NSCameraUsageDescription) | Configured | Info.plist key added |
| Photo Library (NSPhotoLibraryUsageDescription) | Configured | Info.plist key added |
| iCloud Container | Configured | Apple Developer Portal |

## No Configuration Needed

- Location Services: Not required
- HealthKit: Not required
- Apple Watch: Not required
- Siri: Not required
- Background Modes: Not required (local notifications only)

## Verification

- Build succeeded after configuration: Yes
- All entitlements correct: Yes
