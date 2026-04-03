import 'dart:convert';
import 'package:dio/dio.dart';

import '../models/login_models.dart';
import '../api/api_config.dart';
import 'storage_service.dart';
import 'api_interceptor.dart';

class AuthService {
  static const String _loginEndpoint = '/auth/login';
  static const String _signinEndpoint = '/auth/signin';
  static const String _logoutEndpoint = '/auth/logout';
  static const String _userDetailEndpoint = '/user/detail';
  static const String _updateUserDetailEndpoint = '/user/detail';
  static const String _updatePasswordEndpoint = '/user/passwd';
  static const String _resetPasswordEndpoint = '/auth/passwd/reset';
  static const String _userOwnMenuTreeEndpoint = '/menu/user-own/tree';

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

        await _loadUserOwnMenuPermissionsSafely();
        
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

  static Future<LoginResponse?> signIn(
    String username,
    String password, {
    bool rememberMe = true,
  }) async {
    try {
      final signInRequest = SignInRequest(
        username: username,
        password: password,
        expires: -1,
      );

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$_signinEndpoint',
        data: signInRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final signInResponse = LoginResponse.fromJson(jsonData);

        if (signInResponse.status == 200 && signInResponse.result.token.isNotEmpty) {
          await StorageService.saveTokenWithExpiry(
            signInResponse.result.token,
            signInResponse.result.expires,
          );
          await StorageService.saveUserInfo(
            jsonEncode(signInResponse.result.user.toJson()),
          );
          await _loadUserOwnMenuPermissionsSafely();
          return signInResponse;
        }

        throw Exception(signInResponse.message.isNotEmpty
            ? signInResponse.message
            : 'Register failed');
      } else {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message']?.toString() ?? 'Register failed';
          throw Exception(message);
        }
        throw Exception('Register failed');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      if (e.response?.statusMessage != null && e.response!.statusMessage!.isNotEmpty) {
        throw Exception(e.response!.statusMessage!);
      }

      throw Exception('Network error');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Register failed');
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

  static Future<Map<String, dynamic>> getUserDetail() async {
    try {
      final response = await ApiInterceptor.get(
        '${ApiConfig.baseUrl}$_userDetailEndpoint',
      ).timeout(ApiConfig.timeout);

      final data = response.data;
      if (response.statusCode != 200 || data is! Map<String, dynamic>) {
        throw Exception('Failed to load user detail');
      }

      if (data['status'] != 200) {
        throw Exception(data['message']?.toString() ?? 'Failed to load user detail');
      }

      final result = data['result'];
      if (result is! Map<String, dynamic>) {
        throw Exception('Invalid user detail response');
      }

      return result;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error');
    }
  }

  static Future<void> updateUserDetail({
    required String id,
    required String name,
    required String email,
    required String avatar,
    required String telephone,
    String? orgId,
    String? orgName,
  }) async {
    try {
      final requestBody = {
        'id': id,
        'name': name,
        'email': email,
        'orgId': orgId,
        'orgName': orgName,
        'avatar': avatar,
        'telephone': telephone,
      };

      final response = await ApiInterceptor.put(
        '${ApiConfig.baseUrl}$_updateUserDetailEndpoint',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      final data = response.data;
      if (response.statusCode != 200 || data is! Map<String, dynamic>) {
        throw Exception('Failed');
      }

      if (data['status'] != 200) {
        throw Exception(data['message']?.toString() ?? 'Failed');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error');
    }
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

  static Future<List<Map<String, dynamic>>> getUserOwnMenuPermissions() async {
    try {
      final response = await ApiInterceptor.get(
        '${ApiConfig.baseUrl}$_userOwnMenuTreeEndpoint',
      ).timeout(ApiConfig.timeout);

      final data = response.data;
      if (response.statusCode != 200 || data is! Map<String, dynamic>) {
        throw Exception('Failed to load menu permissions');
      }

      if (data['status'] != 200) {
        throw Exception(
          data['message']?.toString() ?? 'Failed to load menu permissions',
        );
      }

      final result = data['result'];
      if (result is! List) {
        throw Exception('Invalid menu permission response');
      }

      final menuButtonPermissions = _parseMenuButtonPermissions(result);
      await StorageService.saveMenuButtonPermissions(menuButtonPermissions);

      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(e.message ?? 'Network error');
    }
  }

  static Map<String, String> _parseMenuButtonPermissions(List<dynamic> menuTree) {
    final permissions = <String, String>{};

    void walkNode(dynamic node) {
      if (node is! Map<String, dynamic>) {
        return;
      }

      final code = node['code']?.toString().trim() ?? '';
      if (code.isNotEmpty) {
        final buttons = node['buttons'];
        if (buttons is List) {
          for (final button in buttons) {
            if (button is! Map<String, dynamic>) {
              continue;
            }

            final enabled = button['enabled'];
            final granted = button['granted'];
            if (enabled == false || granted == false) {
              continue;
            }

            final id = button['id']?.toString().trim() ?? '';
            if (id.isNotEmpty) {
              final name =
                  button['name']?.toString().trim().isNotEmpty == true
                  ? button['name'].toString().trim()
                  : (button['i18nName']?.toString().trim().isNotEmpty == true
                      ? button['i18nName'].toString().trim()
                      : id);
              permissions['$code:$id'] = name;
            }
          }
        }
      }

      final children = node['children'];
      if (children is List) {
        for (final child in children) {
          walkNode(child);
        }
      }
    }

    for (final item in menuTree) {
      walkNode(item);
    }

    return permissions;
  }

  static Future<void> _loadUserOwnMenuPermissionsSafely() async {
    try {
      await getUserOwnMenuPermissions();
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Load menu permissions error: $e');
      }
    }
  }
}