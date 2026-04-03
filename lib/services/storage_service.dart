import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _loginTimeKey = 'login_time';
  static const String _wifiSsidKey = 'wifi_ssid_';
  static const String _menuButtonPermissionsKey = 'menu_button_permissions';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveTokenWithExpiry(String token, int expiresInMillSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = DateTime.now().millisecondsSinceEpoch;
    final expiryTime = loginTime + expiresInMillSeconds;
    
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_loginTimeKey, loginTime);
    await prefs.setInt(_tokenExpiryKey, expiryTime);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // static Future<String?> getValidToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString(_tokenKey);
  //   final expiryTime = prefs.getInt(_tokenExpiryKey);
    
  //   if (token == null || expiryTime == null) {
  //     return null;
  //   }
    
  //   final currentTime = DateTime.now().millisecondsSinceEpoch;
  //   if (currentTime >= expiryTime) {
  //     // Token expired, clear it
  //     await clearAll();
  //     return null;
  //   }
    
  //   return token;
  // }

  static Future<bool> isTokenValid() async {
    final token = await getToken();
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

  static Future<void> saveWifiConfig(String ssid, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wifiSsidKey + ssid, password);
  }

  static Future<String?> getWifiConfig(String ssid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_wifiSsidKey + ssid);
  }

  static Future<List<String>> getSavedWifiList() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys
        .where((k) => k.startsWith(_wifiSsidKey))
        .map((k) => k.substring(_wifiSsidKey.length))
        .toList();
  }

  static Future<void> saveMenuButtonPermissions(
    Map<String, String> permissions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_menuButtonPermissionsKey, jsonEncode(permissions));
  }

  static Future<Map<String, String>> getMenuButtonPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_menuButtonPermissionsKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return {};
    }

    return decoded.map(
      (key, value) => MapEntry(
        key,
        value?.toString() ?? '',
      ),
    );
  }

  static Future<bool> hasPermission(String key) async {
    final permissions = await getMenuButtonPermissions();
    final value = permissions[key];
    return value != null && value.isNotEmpty;
  }

  static Future<void> removeMenuButtonPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_menuButtonPermissionsKey);
  }
}