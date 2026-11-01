# Nivetha Catering Customer App

Flutter customer app using Provider, Dio, GoRouter, and Flutter Secure Storage.

## API configuration

The app defaults to the deployed API at `https://nivetha-fastapi-backend.onrender.com/api/v1`.
Override it at build/run time with Dart's `API_BASE_URL` define:

```sh
flutter run --dart-define=API_BASE_URL=https://your-api-host/api/v1
```

For Android emulators, a local API can be reached with `http://10.0.2.2:8000/api/v1`.

The initial authentication flow uses the existing backend routes:

- `POST /auth/register`
- `POST /auth/login`
- `GET /customers/me`

The backend returns `access_token`; the app stores it using platform secure storage and sends it as a bearer token on API requests.

## Dependencies

After dependency changes are approved for installation, run `flutter pub get` before analyzing or building. The current foundation declares Provider, Dio, GoRouter, and Flutter Secure Storage in `pubspec.yaml`.
