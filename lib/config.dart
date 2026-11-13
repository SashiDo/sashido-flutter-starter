/// Your app's keys, from the SashiDo dashboard: App Settings › Security & Keys.
/// Passed at build time: flutter run --dart-define-from-file=config.json
class Config {
  static const appId = String.fromEnvironment('PARSE_APP_ID');
  static const clientKey = String.fromEnvironment('PARSE_CLIENT_KEY');
  static const serverUrl = String.fromEnvironment('PARSE_SERVER_URL');

  /// Optional, for live updates: the LiveQuery URL Address (wss://...)
  static const liveQueryUrl = String.fromEnvironment('PARSE_LIVE_QUERY_URL');

  static bool get isSet => appId.isNotEmpty && serverUrl.isNotEmpty;
  static bool get liveQueries => liveQueryUrl.isNotEmpty;
}
