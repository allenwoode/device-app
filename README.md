# Device Monitor

A Flutter-based IoT device monitoring application with real-time alerts and background notifications.

## Features

- 📱 Cross-platform (Android, iOS)
- 🔔 Real-time device alert notifications
- 🌐 WebSocket-based monitoring
- 🔄 Background service for continuous monitoring
- 📊 Dashboard with usage statistics and alerts
- 🌍 Multi-language support (English, Chinese)
- 🔐 Secure authentication
- 📲 Local notifications even when app is closed

## Background Service & Notifications

This app uses `flutter_local_notifications` and `flutter_background_service` to provide continuous device monitoring with local notifications.

### Key Features:
- ✅ Background service runs even when app is closed
- ✅ Real-time WebSocket connection to monitor device alerts
- ✅ Local notifications with sound and vibration
- ✅ Multiple notification channels (default, alerts, background service)
- ✅ Severity-based notifications (info, warning, severe)
- ✅ Automatic reconnection on network issues

### Quick Start:

```dart
import 'package:device/services/notification_service.dart';

final notificationService = NotificationService();

// Initialize
await notificationService.initialize();

// Request permission
await notificationService.requestPermission();

// Start background monitoring
await notificationService.startBackgroundService();

// Monitor a device
await notificationService.requestMonitoringDevice(
  'device-id',
  'Device Name'
);
```

For detailed documentation, see [BACKGROUND_SERVICE_GUIDE.md](BACKGROUND_SERVICE_GUIDE.md)

### Demo Page

A demo page is available at `lib/views/background_monitor_demo_page.dart` that shows:
- Service status
- Start/Stop monitoring
- Device selection
- Test notifications

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.0
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Building

```bash
# Android APK
flutter build apk

# iOS (macOS only)
flutter build ios

# Web
flutter build web

# Windows
flutter build windows

# Linux
flutter build linux
```

## Project Structure

```
lib/
├── api/                  # API configuration
├── assets/              # JSON mock data
├── ble/                 # Bluetooth Low Energy
├── config/              # App configuration
├── events/              # Event bus
├── l10n/                # Localization files
├── models/              # Data models
├── routes/              # App routes
├── services/            # Services (Auth, Device, Notification, WebSocket)
├── views/               # UI pages
└── widgets/             # Reusable widgets
```

## Key Services

### NotificationService
Manages local notifications and background service:
- Initialize notifications
- Request permissions
- Start/stop background service
- Monitor device alerts
- Show notifications

### WebSocketService
Handles real-time communication:
- Connect/disconnect
- Subscribe to device topics
- Receive alert messages
- Auto-reconnection

### DeviceService
Device management:
- Fetch device list
- Get device details
- Device alerts and logs
- Usage statistics

### AuthService
Authentication:
- Login/logout
- Token management
- Session handling

## Color Scheme

- Primary: #f08200 (Orange)
- Success: #55bf4f (Green)
- Info: #00a0e9 (Blue)
- Background: #f3f3f3 (Light Gray)
- Icons: #313131 (Dark Gray)

## License

This project is licensed under the MIT License.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Background Service Guide](BACKGROUND_SERVICE_GUIDE.md)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)