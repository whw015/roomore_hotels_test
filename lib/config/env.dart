class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://brq25.com/roomore-api/api/public',
  );

  static const String uploadsBaseUrl = String.fromEnvironment(
    'UPLOADS_BASE_URL',
    defaultValue: 'https://brq25.com/roomore-api/api/uploads/',
  );

  static const bool useLocalPhpApi = bool.fromEnvironment(
    'USE_LOCAL_PHP_API',
    defaultValue: false,
  );

  // Auto-enable HTTP services when pointing to localhost
  static bool get useHttpServices {
    // Explicit flag only. No localhost auto-detection to avoid accidental overrides.
    return useLocalPhpApi;
  }
}
