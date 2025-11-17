import 'dart:convert';

import '../models/login_models.dart';
import '../api/api_config.dart';
import 'storage_service.dart';
import 'api_interceptor.dart';

class AuthService {
  static const String _loginEndpoint = '/auth/login';
  static const String _logoutEndpoint = '/auth/logout';
  static const String _updatePasswordEndpoint = '/user/passwd';
  static const String _resetPasswordEndpoint = '/auth/passwd/reset';

  static Future<LoginResponse?> login(String username, String password) async {
    try {
      final loginRequest = LoginRequest(
        username: username,
        password: password,
        expires: -1,
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

  static Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final requestData = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };

      final response = await ApiInterceptor.put(
        '${ApiConfig.baseUrl}$_updatePasswordEndpoint',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        // Check if the response indicates success
        if (jsonData['status'] == 200) {
          return true;
        } else {
          print('Password update failed: ${jsonData['message']}');
          return false;
        }
      } else if (ApiConfig.enableLogging) {
        print('Password update failed with status: ${response.statusCode}');
        print('Response body: ${response.data}');
        return false;
      }
      return false;
    } catch (e) {
      print('Password update error: $e');
      return false;
    }
  }

  static Future<String> reset(String username) async {
    try {
      final requestData = {
        'username': username,
      };

      final response = await ApiInterceptor.put(
        '${ApiConfig.baseUrl}$_resetPasswordEndpoint',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        // Check if the response indicates success
        if (jsonData['status'] == 200) {
          // Return the new password from result field
          return jsonData['result'] ?? '';
        } else {
          print('Password reset failed: ${jsonData['message']}');
          return '';
        }
      }

      if (ApiConfig.enableLogging) {
        print('Password reset failed with status: ${response.statusCode}');
        print('Response body: ${response.data}');
      }
      return '';
    } catch (e) {
      print('Password reset error: $e');
      return '';
    }
  }
}