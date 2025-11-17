import 'dart:convert';

import 'package:device/models/device_models.dart';
import 'package:flutter/services.dart';
import 'package:device/api/api_config.dart';
import 'api_interceptor.dart';
import 'auth_service.dart';

class DeviceService {
  // Device endpoints
  static const String devicesEndpoint = '/device/instance/query';
  static const String dashboardDevicesEndpoint = '/device/instance/dashboard/count';
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
          {"name": "createTime", "order": "asc"},
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

  static Future<DashboardDevices> getDashboardDevices() async {
    try {
      // Prepare request body for POST request
      final requestBody = {'terms': []};

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}$dashboardDevicesEndpoint',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Dashboard Devices API Response Status: ${response.statusCode}');
        print('Dashboard Devices API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('result') &&
              responseData['result'] is Map<String, dynamic>) {
                return DashboardDevices.fromJson(responseData['result']);
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

  static Future<DashboardDevices> _loadLocalDashboardDevices() async {
    return DashboardDevices(total: 0, onlineCount: 0, offlineCount: 0);
  }

  static Future<List<Dashboard>> getDashboardUsage() async {
    try {
      // Try API first - GET request to /report/usage/top
      final response = await ApiInterceptor.get(
        '${ApiConfig.baseUrl}/report/usage/top',
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Dashboard Usage API Response Status: ${response.statusCode}');
        print('Dashboard Usage API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['result'] is List) {
          final List<dynamic> resultList = responseData['result'];
          return resultList.map((item) => Dashboard.fromJson(item)).toList();
        }
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }

      return [];
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Dashboard usage API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDashboardUsage();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<Dashboard>> _loadLocalDashboardUsage() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/dashboard_usage.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      if (data['result'] is List) {
        final List<dynamic> resultList = data['result'];
        return resultList.map((item) => Dashboard.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load dashboard usage data: $e');
    }
  }

  static Future<List<Dashboard>> getDashboardUsageDevice() async {
    try {
      // Prepare request body for POST request
      final requestBody = {
        'pageIndex': 0,
        'pageSize': 12,
        'terms': [],
        'sorts': [],
      };

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/report/usage/_query',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Dashboard Usage Device API Response Status: ${response.statusCode}');
        print('Dashboard Usage Device API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final List<dynamic> data = responseData['result']['data'];
          return data.map((item) => Dashboard.fromJson(item)).toList();
        }
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }

      return [];
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Dashboard usage device API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDashboardUsageDevice();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<Dashboard>> _loadLocalDashboardUsageDevice() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/dashboard_device_usage.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      if (data['result'] is List) {
        final List<dynamic> resultList = data['result'];
        return resultList.map((item) => Dashboard.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load dashboard usage device data: $e');
    }
  }

  static Future<List<Dashboard>> getDashboardAlertCount() async {
    try {
      // Prepare request body for POST request
      final requestBody = {
        'terms': [],
        'sorts': [
          {'name':'amount', 'order':'desc'}
        ],
      };

      // Try API first
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/report/alarm/count',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Alert Count API Response Status: ${response.statusCode}');
        print('Device Alert Count API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['result'] is List) {
          final List<dynamic> resultList = responseData['result'];
          return resultList.map((item) => Dashboard.fromJson(item)).toList();
        }
        return [];
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print(
            'Device alert count API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceAlertCount();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<Dashboard>> getDashboardDeviceLog() async {
    try {
      // Prepare request body for POST request
      final requestBody = {
        'terms': [],
        'sorts': [
          {'name':'amount', 'order':'desc'}
        ],
      };

      // Try API first
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/report/operate/count',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Dashboard Log Count API Response Status: ${response.statusCode}');
        print('Dashboard Log Count API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['result'] is List) {
          final List<dynamic> resultList = responseData['result'];

          // Transform DeviceLogCount list to DashboardUsageDevice list
          return resultList.map((item) => Dashboard.fromJson(item)).toList();
        }
        return [];
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Dashboard device log API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDashboardDeviceLog();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<Dashboard>> _loadLocalDashboardDeviceLog() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/dashboard_device_log.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      if (data['result'] is List) {
        final List<dynamic> resultList = data['result'];
        return resultList
            .map((item) => Dashboard.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load dashboard device log data: $e');
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

  static Future<DeviceUsageResponse> getDeviceUsage({
    required String deviceId,
    int pageIndex = 0,
    int pageSize = 12,
  }) async {
    try {
      // Prepare request body for POST request
      final requestBody = {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'terms': [
          {
            'column': 'deviceId',
            'term': 'eq',
            'value': deviceId,
          }
        ],
        'sorts': [
          {
            'name': 'timestamp',
            'order': 'desc',
          }
        ],
      };

      // Try API first
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/device-instance/today/$deviceId/event/LOCK_OPEN_TYPE',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Usage API Response Status: ${response.statusCode}');
        print('Device Usage API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return DeviceUsageResponse.fromJson(responseData);
        }

        // Return empty response if data structure is invalid
        return DeviceUsageResponse(
          message: 'success',
          result: DeviceUsageResult(
            pageIndex: pageIndex,
            pageSize: pageSize,
            total: 0,
            data: [],
          ),
          status: 200,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device usage API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceUsageResponse(pageIndex, pageSize);
      } else {
        rethrow;
      }
    }
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

  static Future<DeviceUsageResponse> _loadLocalDeviceUsageResponse(
    int pageIndex,
    int pageSize,
  ) async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_usage.json',
      );
      final json = jsonDecode(response);
      return DeviceUsageResponse.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load device usage data: $e');
    }
  }

  static Future<List<DeviceUsageCount>> getDeviceUsageCount({
    required String deviceId,
  }) async {
    try {
      // Try API first
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/device-instance/today/count/$deviceId/event/LOCK_OPEN_TYPE',
        data: {},
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Usage Count API Response Status: ${response.statusCode}');
        print('Device Usage Count API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['result'] is List) {
          final List<dynamic> resultList = responseData['result'];
          return resultList.map((item) => DeviceUsageCount.fromJson(item)).toList();
        }
        return [];
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Device usage count API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceUsageCount();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<DeviceUsageCount>> _loadLocalDeviceUsageCount() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_usage_count.json',
      );
      final json = jsonDecode(response);
      if (json['result'] is List) {
        final List<dynamic> resultList = json['result'];
        return resultList.map((item) => DeviceUsageCount.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load device usage count data: $e');
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

  static Future<List<DeviceOperateLog>> getDeviceLogs({
    required String deviceId,
    int pageIndex = 0,
    int pageSize = 12,
  }) async {
    try {
      // Try API first (commented for now, using local fallback)
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/report/operate/_query',
        data: {
          'pageIndex': pageIndex,
          'pageSize': pageSize,
          'terms': [
            {
              "column":"deviceId", 
              "term":"eq", 
              "value": deviceId
            },
          ],
          'sorts': [
            {
              "name": "timestamp",
              "order": "desc"
            }
          ]
        },
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Log API Response Status: ${response.statusCode}');
        print('Device Log API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        List<dynamic> dataList = response.data['result']['data'] ?? [];
        return dataList.map((item) => DeviceOperateLog.fromJson(item)).toList();
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
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

  static Future<List<DeviceOperateLog>> _loadLocalDeviceLogs() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_log.json',
      );
      final json = jsonDecode(response);
      List<dynamic> dataList = json['result']['data'] ?? [];
      return dataList.map((item) => DeviceOperateLog.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load device log data: $e');
    }
  }

  static Future<List<Dashboard>> getDeviceLogCount({
    required String deviceId,
  }) async {
    try {
      // Prepare request body for POST request
      final requestBody = {
        'terms': [
          {
            'column': 'deviceId',
            'term': 'eq',
            'value': deviceId,
          }
        ],
        'sorts': [],
      };

      // Try API first
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/report/operate/count',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Log Count API Response Status: ${response.statusCode}');
        print('Device Log Count API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['result'] is List) {
          final List<dynamic> resultList = responseData['result'];
          return resultList
              .map((item) => Dashboard.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print(
            'Device log count API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceLogCount();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<Dashboard>> _loadLocalDeviceLogCount() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_log_count.json',
      );
      final json = jsonDecode(response);
      if (json['result'] is List) {
        final List<dynamic> resultList = json['result'];
        return resultList
            .map((item) => Dashboard.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load device log count data: $e');
    }
  }

static Future<List<DeviceAlert>> getDeviceAlerts({
    required String deviceId,
    int pageIndex = 0,
    int pageSize = 12,
  }) async {
    try {
      // Prepare request body for POST request
      final requestBody = {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'terms': [
          {
            "column": "deviceId",
            "term": "eq",
            "value": deviceId
          }
        ],
        'sorts': [
          {
            "name": "timestamp",
            "order": "desc"
          }
        ],
      };

      // Try API first
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/report/alarm/_query',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Alert API Response Status: ${response.statusCode}');
        print('Device Alert API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final List<dynamic> resultList = responseData['result']['data'];
          return resultList
              .map((item) => DeviceAlert.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print(
            'Device alert count API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceAlerts();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<Dashboard>> getDeviceAlertCount({
    required String deviceId,
  }) async {
    try {
      // Prepare request body for POST request
      final requestBody = {
        'terms': [
          {
            'column': 'deviceId',
            'term': 'eq',
            'value': deviceId,
          }
        ],
        'sorts': [],
      };

      // Try API first
      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/report/alarm/count',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Alert Count API Response Status: ${response.statusCode}');
        print('Device Alert Count API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['result'] is List) {
          final List<dynamic> resultList = responseData['result'];
          return resultList
              .map((item) => Dashboard.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print(
            'Device alert count API request failed: $e, falling back to local data');
      }

      if (ApiConfig.useLocalFallback) {
        return await _loadLocalDeviceAlertCount();
      } else {
        rethrow;
      }
    }
  }

  static Future<List<Dashboard>> _loadLocalDeviceAlertCount() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/assets/device_alert_count.json',
      );
      final json = jsonDecode(response);
      if (json['result'] is List) {
        final List<dynamic> resultList = json['result'];
        return resultList
            .map((item) => Dashboard.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load device alert count data: $e');
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

  static Future<bool> submitFeedback({
    required String type,
    required String content,
    String? email,
    String? company,
  }) async {
    try {
      final requestBody = {
        'type': type,
        'content': content,
        'email': email ?? '',
        'company': company ?? '',
      };

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/app/feedback/submit',
        data: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Feedback Submit API Response Status: ${response.statusCode}');
        print('Feedback Submit API Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return responseData['status'] == 200;
        }
      }

      return false;
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Feedback submit API request failed: $e');
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
