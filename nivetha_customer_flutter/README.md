
# Nivetha Catering — Customer App

A Flutter mobile application for customers to explore catering services and manage their event bookings.

## Features

- Customer registration and login
- Secure authentication token storage
- Customer profile
- English and Tamil language support
- Catering booking interface
- API integration with the Nivetha Catering backend
- Android APK build support

## Tech Stack

- Flutter
- Dart
- Provider
- HTTP
- Flutter Secure Storage
- Node.js and Express backend
- MongoDB

## Project Structure

```text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── localization/
│   ├── services/
│   └── theme/
├── presentation/
│   ├── providers/
│   └── screens/
└── main.dart

android/
ios/
web/
pubspec.yaml
README.md
```

## Requirements

- Flutter SDK
- Dart SDK
- Android SDK for Android builds
- Chrome for web testing

## Installation

Clone the repository:

```bash
git clone https://github.com/deepakp2007s-hub/NIVETHA-CATERING.git
```

Open the customer app folder:

```bash
cd nivetha_customer_flutter
```

Install dependencies:

```bash
flutter pub get
```

## Configure Backend

Open:

`lib/core/config/api_config.dart`

Set the API base URL to your deployed backend:

```dart
static const String baseUrl =
    'https://nivetha-catering-api.onrender.com/api';
```

Ensure the backend is running and the required authentication endpoints are available.

## Run on Chrome

```bash
flutter run -d chrome
```

## Run on Android

```bash
flutter devices
flutter run
```

## Build Release APK

```bash
flutter pub get
flutter build apk --release
```

The APK output location is:

`build/app/outputs/flutter-apk/app-release.apk`

## Backend Health Check

Open this URL in a browser to check backend availability:

<https://nivetha-catering-api.onrender.com/api/health>

A successful health response indicates that the health endpoint is reachable. Authentication endpoints should also be tested separately.

## Development Checks

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Important Notes

- Never commit API secrets, passwords, or private credentials.
- Keep the API base URL consistent with the deployed backend.
- Test registration, login, profile, and booking flows before releasing the application.
- Verify Android permissions and authentication behavior before building the final APK.

## Project

**Application:** Nivetha Catering Customer App

**Platform:** Flutter

**Backend:** Nivetha Catering API
