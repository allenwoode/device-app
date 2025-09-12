import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _loginTimeKey = 'login_time';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveTokenWithExpiry(String token, int expiresInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = DateTime.now().millisecondsSinceEpoch;
    final expiryTime = loginTime + expiresInSeconds;
    
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_loginTimeKey, loginTime);
    await prefs.setInt(_tokenExpiryKey, expiryTime);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryTime = prefs.getInt(_tokenExpiryKey);
    
    if (token == null || expiryTime == null) {
      return null;
    }
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime >= expiryTime) {
      // Token expired, clear it
      await clearAll();
      return null;
    }
    
    return token;
  }

  static Future<bool> isTokenValid() async {
    final token = await getValidToken();
    return token != null;
  }

  static Future<int?> getTokenExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokenExpiryKey);
  }

  static Future<int?> getLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_loginTimeKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveUserInfo(String userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, userInfo);
  }

  static Future<String?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userInfoKey);
  }

  static Future<void> removeUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userInfoKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    return await isTokenValid();
  }
}