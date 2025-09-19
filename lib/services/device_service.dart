import 'dart:convert';

import 'package:device/models/device_models.dart';
import 'package:flutter/services.dart';
import 'package:device/api/api_config.dart';
import 'api_interceptor.dart';
import 'auth_service.dart';

class DeviceService {
  // Device endpoints
  static const String devicesEndpoint = '/device/instance/query';
  static const String dashboardDevicesEndpoint =
      '/device/instance/dashboard/count';
  static const String deviceInvokeEndpoint = '/device/invoked';

  static Future<Map<String, dynamic>> getDevices({
    int index = 0,
    int size = 10,
  }) async {
    try {
      // First try to fetch from API
      // Prepare request body for POST request
      final requestBody = {
        'pageIndex': index,
        'pageSize': size,
        // Add any other required parameters here
        'sorts': [
          {"name": "createTime", "order": "desc"},
          {"name": "name", "order": "desc"},
        ],
        "terms": [],
      };

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$devicesEndpoint',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = response.data;

        // API returns: { "result": { "data": [...], "total": 10 } }
        if (responseData.containsKey('result')) {
          final result = responseData['result'];
          final Map<String, dynamic> returnData = {};

          if (result.containsKey('data')) {
            returnData['devices'] = result['data'];
          }
          if (result.containsKey('total')) {
            returnData['total'] = result['total'];
          }
          if (returnData.isNotEmpty) {
            return returnData;
          }
        }

        // Default fallback
        return {'devices': []};
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      // Fallback to local JSON file if API fails
      if (ApiConfig.enableLogging) {
        print('API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDevices();
      } else {
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> getDashboardDevices() async {
    try {
      // Prepare request body for POST request
      final requestBody = {'terms': []};

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$dashboardDevicesEndpoint',
        data: requestBody,
      ).timeout(ApiConfig.timeout);


      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('result') &&
              responseData['result'] is Map<String, dynamic>) {
            return responseData['result'];
          }
        }

        return responseData;
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Dashboard devices API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDashboardDevices();
      } else {
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> _loadLocalDevices() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/devices.json',
      );
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to load device data: $e');
    }
  }

  static Future<DeviceData> getDeviceDetail(String deviceId) async {
    try {
      // Try API first
      final response = await ApiInterceptor.get(
        '${ApiConfig.baseUrl}/device-instance/$deviceId/info',
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return DeviceData.fromJson(response.data['result']);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print(
          'Device detail API request failed: $e, falling back to local data',
        );
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceDetail();
      } else {
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> getDeviceState(
    String deviceId,
    String productId,
  ) async {
    try {
      // Try API first - this is a POST request
      final requestBody = [
        {
          "dashboard": "device",
          "object": productId,
          "measurement": "properties",
          "dimension": "history",
          "params": {
            "deviceId": deviceId,
            "history": 1,
            "properties": ["CHARGE_STATE", "LOCK_STATE", "USED_STATE"],
          },
        },
      ];

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/dashboard/_multi',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print(
          'Device state API request failed: $e, falling back to local data',
        );
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceState();
      } else {
        rethrow;
      }
    }
  }

  static Future<DeviceData> _loadLocalDeviceDetail() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_detail.json',
      );
      return DeviceData.fromJson(json.decode(response)['result']);
    } catch (e) {
      throw Exception('Failed to load device detail data: $e');
    }
  }

  static Future<Map<String, dynamic>> _loadLocalDeviceState() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_state.json',
      );
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to load device state data: $e');
    }
  }

  static Future<Map<String, dynamic>> _loadLocalDashboardDevices() async {
    return {'total': 0, 'onlineCount': 0, 'offlineCount': 0};
  }

  static Future<List<DashboardUsage>> getDashboardUsage() async {
    try {
      // For now, load from local JSON file (can be extended to API call)
      final String response = await rootBundle.loadString(
        'lib/assets/dashboard_usage.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      if (data['result'] is List) {
        final List<dynamic> resultList = data['result'];
        return resultList.map((item) => DashboardUsage.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Failed to load dashboard usage data: $e');
      }
      // Return fallback data
      return [];
    }
  }

  static Future<DashboardAlerts> getDashboardAlerts() async {
    try {
      // For now, load from local JSON file (can be extended to API call)
      final String response = await rootBundle.loadString(
        'lib/assets/dashboard_alerts.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      if (data['result'] is Map<String, dynamic>) {
        return DashboardAlerts.fromJson(data['result']);
      }

      // Return fallback data
      return DashboardAlerts(total: 16, alarmCount: 15, severeCount: 1);
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Failed to load dashboard alerts data: $e');
      }
      // Return fallback data
      return DashboardAlerts(total: 16, alarmCount: 15, severeCount: 1);
    }
  }

  static Future<DashboardMessage> getDashboardMessage() async {
    try {
      // For now, load from local JSON file (can be extended to API call)
      final String response = await rootBundle.loadString(
        'lib/assets/dashboard_message.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      if (data['result'] is Map<String, dynamic>) {
        return DashboardMessage.fromJson(data['result']);
      }

      // Return fallback data
      return DashboardMessage(total: 30, reportCount: 25, functionCount: 5);
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Failed to load dashboard message data: $e');
      }
      // Return fallback data
      return DashboardMessage(total: 30, reportCount: 25, functionCount: 5);
    }
  }

  static Future<bool> invokeDeviceLockOpen({
    required String deviceId,
    required int port,
    String type = "1",
  }) async {
    try {
      // Prepare request body for POST request
      final requestBody = {'port': port, 'type': type};

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$deviceInvokeEndpoint/$deviceId/function/0_LOCK_OPEN_CMD',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Invoke API Response Status: ${response.statusCode}');
        print('Device Invoke API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData['result'] is List) {
            final List<dynamic> results = responseData['result'];
            if (results.isNotEmpty && results.first['success'] == true) {
              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device invoke API request failed: $e');
      }
      return false;
    }
  }

  static Future<List<DeviceUsage>> getDeviceUsage({
    required String deviceId,
  }) async {
    // try {
    //   // Try API first
    //   final response = await ApiInterceptor.post(
    //     '${ApiConfig.baseUrl}/device-instance/$deviceId/event/LOCK_OPEN_TYPE',
    //     data: {
    //       'terms': []
    //     },
    //   ).timeout(ApiConfig.timeout);

    //   if (ApiConfig.enableLogging) {
    //     print('Device Usage API Response Status: ${response.statusCode}');
    //     print('Device Usage API Response Body: ${response.data}');
    //   }

    //   if (response.statusCode == 201) {
    //     List<dynamic> dataList = response.data['result']['data'] ?? [];
    //     return dataList.map((item) => DeviceUsage.fromJson(item)).toList();
    //   } else {
    //     throw HttpException('HTTP ${response.statusCode}: ${response.data}');
    //   }
    // } catch (e) {
    //   if (ApiConfig.enableLogging) {
    //     print('Device usage API request failed: $e, falling back to local data');
    //   }

    //   if (ApiConfig.useLocalFallback) {
    //     return await _loadLocalDeviceUsage();
    //   } else {
    //     rethrow;
    //   }
    // }

    if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceUsage();
    }
    return [];
  }

  static Future<List<DeviceUsage>> _loadLocalDeviceUsage() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_usage.json',
      );
      final json = jsonDecode(response);
      List<dynamic> dataList = json['result']['data'] ?? [];
      return dataList.map((item) => DeviceUsage.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load device usage data: $e');
    }
  }

  static Future<List<DeviceAlert>> getDeviceAlerts({
    required String deviceId,
    int pageIndex = 0,
    int pageSize = 12,
  }) async {
    try {
      // Try API first (commented for now, using local fallback)
      // final response = await ApiInterceptor.post(
      //   '${ApiConfig.baseUrl}/device-instance/$deviceId/alerts',
      //   data: {
      //     'pageIndex': pageIndex,
      //     'pageSize': pageSize,
      //   },
      // ).timeout(ApiConfig.timeout);

      // if (ApiConfig.enableLogging) {
      //   print('Device Alert API Response Status: ${response.statusCode}');
      //   print('Device Alert API Response Body: ${response.data}');
      // }

      // if (response.statusCode == 200) {
      //   DeviceAlertResponse alertResponse = DeviceAlertResponse.fromJson(response.data);
      //   return alertResponse.result.data;
      // } else {
      //   throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      // }

      // For now, always use local fallback
      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceAlerts();
      }
      return [];
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device alert API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceAlerts();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<DeviceAlert>> _loadLocalDeviceAlerts() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_alert.json',
      );
      final json = jsonDecode(response);
      List<dynamic> dataList = json['result']['data'] ?? [];
      return dataList.map((item) => DeviceAlert.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load device alert data: $e');
    }
  }

  static Future<List<DeviceLog>> getDeviceLogs({
    required String deviceId,
    int pageIndex = 0,
    int pageSize = 12,
  }) async {
    try {
      // Try API first (commented for now, using local fallback)
      // final response = await ApiInterceptor.post(
      //   '${ApiConfig.baseUrl}/device-instance/$deviceId/logs',
      //   data: {
      //     'pageIndex': pageIndex,
      //     'pageSize': pageSize,
      //   },
      // ).timeout(ApiConfig.timeout);

      // if (ApiConfig.enableLogging) {
      //   print('Device Log API Response Status: ${response.statusCode}');
      //   print('Device Log API Response Body: ${response.data}');
      // }

      // if (response.statusCode == 200) {
      //   List<dynamic> dataList = response.data['result']['data'] ?? [];
      //   return dataList.map((item) => DeviceLog.fromJson(item)).toList();
      // } else {
      //   throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      // }

      // For now, always use local fallback
      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceLogs();
      }
      return [];
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device log API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceLogs();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<DeviceLog>> _loadLocalDeviceLogs() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_log.json',
      );
      final json = jsonDecode(response);
      List<dynamic> dataList = json['result']['data'] ?? [];
      return dataList.map((item) => DeviceLog.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load device log data: $e');
    }
  }

  static Future<bool> bindDevice({
    required String deviceId,
  }) async {
    try {
      // Get current user to retrieve orgId
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('无法获取用户信息');
      }

      final orgId = currentUser.orgId;
      if (orgId.isEmpty) {
        throw Exception('无法获取用户组织信息');
      }

      // Prepare request body - array of device IDs
      final requestBody = [deviceId];

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/assets/bind/$orgId/device',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Bind API Response Status: ${response.statusCode}');
        print('Device Bind API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return responseData['status'] == 200 &&
                 responseData['message'] == 'success';
        }
      }

      return false;
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device bind API request failed: $e');
      }
      return false;
    }
  }

  static Future<bool> unbindDevice({
    required String deviceId,
  }) async {
    try {
      // Get current user to retrieve orgId
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('无法获取用户信息');
      }

      final orgId = currentUser.orgId;
      if (orgId.isEmpty) {
        throw Exception('无法获取用户组织信息');
      }

      // Prepare request body - array of device IDs
      final requestBody = [deviceId];

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/assets/unbind/$orgId/device',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Unbind API Response Status: ${response.statusCode}');
        print('Device Unbind API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return responseData['status'] == 200 &&
                 responseData['message'] == 'success';
        }
      }

      return false;
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device unbind API request failed: $e');
      }
      return false;
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}
