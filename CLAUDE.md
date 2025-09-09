# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application named "device" - a cross-platform mobile/desktop app project. The project is in early development stage with minimal implementation.

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Run for specific platforms
flutter run -d chrome      # Web
flutter run -d windows     # Windows desktop
flutter run -d linux       # Linux desktop

# Build for production
flutter build apk          # Android APK
flutter build ios          # iOS (macOS only)
flutter build web          # Web
flutter build windows      # Windows desktop
flutter build linux        # Linux desktop

# Run tests
flutter test

# Run static analysis
flutter analyze

# Format code
dart format .
```

### Development Workflow
```bash
# Hot reload during development (press 'r' in terminal while app is running)
# Hot restart (press 'R' in terminal while app is running)

# Check Flutter installation and connected devices
flutter doctor

# List available devices
flutter devices
```

## Project Structure

### Core Application Files
- `lib/main.dart` - Application entry point, contains `MyApp` root widget
- `lib/views/main_page.dart` - Main page widget (currently placeholder implementation)

### Configuration
- `pubspec.yaml` - Project dependencies and metadata
  - Uses Flutter SDK ^3.9.0
  - Dependencies: flutter, cupertino_icons, google_fonts
  - Dev dependencies: flutter_test, flutter_lints
- `analysis_options.yaml` - Dart/Flutter linting configuration using flutter_lints package

### Platform Support
The project includes platform-specific code for:
- Android (`android/`)
- iOS (`ios/`)
- Web (`web/`)
- Linux (`linux/`)
- macOS (`macos/`)
- Windows (`windows/`)

### Testing
- `test/widget_test.dart` - Contains default counter app test (needs updating to match actual app)

## Architecture Notes

- Uses Material Design as the primary UI framework
- Theme configured with `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
- Currently minimal implementation with `MainPage` showing a placeholder widget
- The test file references a counter app that doesn't match the current implementation

## Development Notes

- The main page currently displays a placeholder widget - this is the starting point for UI development
- Tests need to be updated to match the actual application functionality
- No custom assets or fonts are currently configured
- Uses standard Flutter project structure and conventions