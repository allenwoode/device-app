import 'dart:convert';

import 'package:device/models/device_models.dart';
import 'package:flutter/services.dart';
import 'package:device/api/api_config.dart';
import 'api_interceptor.dart';

class DeviceService {

  // Device endpoints
  static const String devicesEndpoint = '/device/instance/query';
  static const String dashboardDevicesEndpoint = '/device/instance/dashboard/count';
  static const String deviceInvokeEndpoint = '/device/invoked';
  
  static Future<Map<String, dynamic>> getDevices({int index = 0, int size = 5}) async {
    try {
      // First try to fetch from API
      // Prepare request body for POST request
      final requestBody = {
        'pageIndex': index,
        'pageSize': size,
        // Add any other required parameters here
        'sorts': [
          {
            "name": "createTime",
            "order": "desc"
        },
        {
            "name": "name",
            "order": "desc"
        }
        ],
        "terms": []
      };
      
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$devicesEndpoint',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        if (ApiConfig.enableLogging) {
          print('Successfully fetched devices from API');
        }
        
        final responseData = response.data;
        // Handle the actual API response structure
        if (responseData is Map<String, dynamic>) {
          // API returns: { "result": { "data": [...], "total": 10 } }
          if (responseData.containsKey('result') && 
              responseData['result'] is Map<String, dynamic>) {
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

        }
        // If response is a list, wrap it
        else if (responseData is List) {
          return {'devices': responseData};
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
      final requestBody = {
        'terms': []
      };

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$dashboardDevicesEndpoint',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Dashboard Devices API Response Status: ${response.statusCode}');
        print('Dashboard Devices API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        if (ApiConfig.enableLogging) {
          print('Successfully fetched dashboard devices from API');
        }

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
      final String response = await rootBundle.loadString('lib/assets/devices.json');
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to load device data: $e');
    }
  }

  static Future<Map<String, dynamic>> getDeviceDetail(String deviceId) async {
    try {
      // Try API first
      final response = await ApiInterceptor.get(
        '${ApiConfig.baseUrl}/device-instance/$deviceId/info',
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Detail API Response Status: ${response.statusCode}');
        print('Device Detail API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device detail API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceDetail();
      } else {
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> getDeviceState(String deviceId, String productId) async {
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
            "properties": [
              "CHARGE_STATE",
              "LOCK_STATE", 
              "USED_STATE"
            ]
          }
        }
      ];

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/dashboard/_multi',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device State API Response Status: ${response.statusCode}');
        print('Device State API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device state API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceState();
      } else {
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> _loadLocalDeviceDetail() async {
    try {
      final String response = await rootBundle.loadString('lib/assets/device_detail.json');
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to load device detail data: $e');
    }
  }

  static Future<Map<String, dynamic>> _loadLocalDeviceState() async {
    try {
      final String response = await rootBundle.loadString('lib/assets/device_state.json');
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to load device state data: $e');
    }
  }

  static Future<Map<String, dynamic>> _loadLocalDashboardDevices() async {
    return {
      'total': 6,
      'onlineCount': 0,
      'offlineCount': 6
    };
  }

  static Future<List<DashboardUsage>> getDashboardUsage() async {
    try {
      // For now, load from local JSON file (can be extended to API call)
      final String response = await rootBundle.loadString('lib/assets/dashboard_usage.json');
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
      final String response = await rootBundle.loadString('lib/assets/dashboard_alerts.json');
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
      final String response = await rootBundle.loadString('lib/assets/dashboard_message.json');
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
      final requestBody = {
        'port': port,
        'type': type,
      };

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
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => 'HttpException: $message';
}

