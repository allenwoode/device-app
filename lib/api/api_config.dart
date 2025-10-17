
class ApiConfig {
  static const String baseUrl = 'http://192.168.2.137:8848';
  //static const String baseUrl = 'http://114.55.146.54:8848';
  static const Duration timeout = Duration(seconds: 10);
  
  // Common headers with dynamic token
  // static Future<Map<String, String>> get defaultHeaders async {
  //   final token = await StorageService.getToken();
  //   print('header token ===> $token');
  //   return {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //     'X-Access-Token': token ?? '',
  //   };
  // }
  
  // Synchronous headers for when token is already known
  // static Map<String, String> headersWithToken(String token) => {
  //   'Content-Type': 'application/json',
  //   'Accept': 'application/json',
  //   'X-Access-Token': '347f459b92e79cbdc150f22511f49d9f',
  // };
  
  // Basic headers without token (for login)
  // static Map<String, String> get basicHeaders => {
  //   'Content-Type': 'application/json',
  //   'Accept': 'application/json',
  // };
  
  // // Environment-specific configurations
  static bool get useLocalFallback => true;
  static bool get enableLogging => true;
}