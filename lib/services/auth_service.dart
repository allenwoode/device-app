import 'dart:convert';

import '../models/login_models.dart';
import '../api/api_config.dart';
import 'storage_service.dart';
import 'api_interceptor.dart';

class AuthService {
  static const String _loginEndpoint = '/auth/login';
  static const String _logoutEndpoint = '/auth/logout';

  static Future<LoginResponse?> login(String username, String password) async {
    try {
      final loginRequest = LoginRequest(
        username: username,
        password: password,
        expires: 7200000,
      );

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$_loginEndpoint',
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final loginResponse = LoginResponse.fromJson(jsonData);
        
        // Save token with expiration and user info to local storage
        await StorageService.saveTokenWithExpiry(
          loginResponse.result.token,
          loginResponse.result.expires,
        );
        await StorageService.saveUserInfo(jsonEncode(loginResponse.result.user.toJson()));
        
        return loginResponse;
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<bool> logout() async {
    try {
      // Call logout API
      final response = await ApiInterceptor.get(
        '${ApiConfig.baseUrl}$_logoutEndpoint',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final logoutResponse = LogoutResponse.fromJson(jsonData);
        
        if (logoutResponse.status == 200 && logoutResponse.result) {
          // Clear stored user session data after successful API call
          await StorageService.clearAll();
          return true;
        } else {
          print('Logout API failed: ${logoutResponse.message}');
          // Still clear local data even if API fails
          await StorageService.clearAll();
          return true;
        }
      } else {
        print('Logout failed with status: ${response.statusCode}');
        print('Response body: ${response.data}');
        // Clear local data even if API fails
        await StorageService.clearAll();
        return true;
      }
    } catch (e) {
      print('Logout error: $e');
      // Clear local data even if API fails
      await StorageService.clearAll();
      return true;
    }
  }

  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  static Future<User?> getCurrentUser() async {
    final isValid = await StorageService.isTokenValid();
    if (!isValid) {
      return null;
    }
    
    final userInfoString = await StorageService.getUserInfo();
    if (userInfoString != null) {
      final userJson = jsonDecode(userInfoString);
      return User.fromJson(userJson);
    }
    
    return null;
  }

  static bool isTokenValid(String? token) {
    return token != null && token.isNotEmpty;
  }
}