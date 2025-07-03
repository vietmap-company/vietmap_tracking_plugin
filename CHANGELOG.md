# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-12-19

### Added
- **Initial Release** - Complete GPS tracking plugin for Flutter
- **Background Location Tracking** - Continuous location tracking when app is in background
- **Configurable Tracking Intervals** - Set custom intervals (default 30 seconds) for location collection
- **HTTP API Integration** - Direct integration with Vietmap tracking API
- **Automatic Retry Logic** - Exponential backoff retry for failed requests
- **Offline Location Caching** - Store failed locations locally and retry when online
- **Real-time Location Sending** - Immediate location transmission to server
- **Native Platform Support** - Full Android and iOS implementations
- **Comprehensive Error Handling** - Robust error management and recovery
- **Configurable Parameters** - Customizable timeouts, retry attempts, and intervals
- **Permission Management** - Automatic location permission handling
- **Example Application** - Complete demo app with all features

### Features
- ✅ Easy SDK initialization with API key and endpoint
- ✅ Background location service with notification support
- ✅ Dynamic tracking interval updates (15s, 30s, 60s, etc.)
- ✅ Connection testing and health checks
- ✅ Cached location management and clearing
- ✅ Platform-specific implementations (Android/iOS)
- ✅ Comprehensive documentation and usage examples
- ✅ Unit tests for core functionality

### Platform Support
- **Android**: API level 23+ (Android 6.0+)
- **iOS**: iOS 11.0+

### Dependencies
- `background_location_2: ^0.16.3`
- `connectivity_plus: ^6.1.4`
- `flutter_background_service: ^5.1.0`
- `flutter_local_notifications: ^19.3.0`
- `geolocator: ^14.0.1`
- `http: ^1.1.0`
- `plugin_platform_interface: ^2.0.2`
- `shared_preferences: ^2.5.3`
