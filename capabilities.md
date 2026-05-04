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
| Push Notifications | Pending | Xcode project settings |
| iCloud (CloudKit) | Pending | Xcode project settings |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| Camera (NSCameraUsageDescription) | Pending | Add Info.plist key |
| Photo Library (NSPhotoLibraryUsageDescription) | Pending | Add Info.plist key |
| iCloud Container | Pending | Configure in Apple Developer Portal |

## No Configuration Needed
- Location Services: Not required
- HealthKit: Not required (Phase 2)
- Apple Watch: Not required
- Siri: Not required
- Background Modes: Not required (local notifications only)

## Verification
- Build succeeded after configuration: Pending
- All entitlements correct: Pending
