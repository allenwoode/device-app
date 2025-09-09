class ApiConfig {
  static const String baseUrl = 'http://192.168.2.137:8848';
  static const Duration timeout = Duration(seconds: 10);
  
  // Device endpoints
  static const String devicesEndpoint = '/device/instance/query';
  static const String deviceDetailEndpoint = '/api/devices/{id}';
  
  // Authentication endpoints (for future use)
  static const String loginEndpoint = '/api/auth/login';
  static const String refreshTokenEndpoint = '/api/auth/refresh';
  
  // Common headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Environment-specific configurations
  static bool get useLocalFallback => true;
  static bool get enableLogging => true;
}