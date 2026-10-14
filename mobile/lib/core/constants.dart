class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );
  static const int meshRangeMeters = 200;
  static const int audioSampleRate = 16000;
  static const int targetAudioLatencyMs = 100;
  static const Duration otpTtl = Duration(minutes: 3);
}
