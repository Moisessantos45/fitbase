class Env {
  static const String apiBaseV1 = String.fromEnvironment(
    'API_BASE_V1',
    defaultValue: 'http://192.168.100.54:4107/api/v1',
  );
}
