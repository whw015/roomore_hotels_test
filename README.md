# roomore_hotels_test

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API configuration (local PHP backend)

You can point the app to the local backend and match endpoint shapes via dart-define flags:

```
flutter run \
  --dart-define=API_BASE_URL=http://localhost/roomore-api/api/public \
  --dart-define=UPLOADS_BASE_URL=http://localhost/roomore-api/api/uploads/ \
  --dart-define=USE_LOCAL_PHP_API=true
```

Defaults continue to target the production-like endpoints, so these flags are optional.
