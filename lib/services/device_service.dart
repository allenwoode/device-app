import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:device/api/api_config.dart';

class DeviceService {

  // Device endpoints
  static const String devicesEndpoint = '/device/instance/detail/_query';
  static const String deviceDetailEndpoint = '/api/devices/{id}';
  
  static Future<Map<String, dynamic>> getDevices({int index = 0, int size = 5}) async {
    try {
      // First try to fetch from API
      final uri = Uri.parse('${ApiConfig.baseUrl}$devicesEndpoint');
      // Prepare request body for POST request
      final requestBody = json.encode({
        'pageIndex': index,
        'pageSize': size,
        // Add any other required parameters here
        'sorts': [
          {
            "name": "createTime",
            "order": "asc"
        },
        {
            "name": "name",
            "order": "desc"
        }
        ],
        "terms": []
      });
      
      final headers = await ApiConfig.defaultHeaders;
      final response = await http.post(
        uri,
        headers: headers,
        body: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (ApiConfig.enableLogging) {
          print('Successfully fetched devices from API');
        }
        final responseData = json.decode(response.body);
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
          
          // Fallback: if response has 'data' field directly
          else if (responseData.containsKey('data')) {
            return {'devices': responseData['data']};
          }
          // If response is already in expected format
          else if (responseData.containsKey('devices')) {
            return responseData;
          }
        }
        // If response is a list, wrap it
        else if (responseData is List) {
          return {'devices': responseData};
        }
        
        // Default fallback
        return {'devices': []};
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/device-instance/$deviceId/detail');
      final headers = await ApiConfig.defaultHeaders;
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device Detail API Response Status: ${response.statusCode}');
        print('Device Detail API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/dashboard/_multi');
      final requestBody = json.encode([
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
      ]);

      final headers = await ApiConfig.defaultHeaders;
      final response = await http.post(
        uri,
        headers: headers,
        body: requestBody,
      ).timeout(ApiConfig.timeout);

      if (ApiConfig.enableLogging) {
        print('Device State API Response Status: ${response.statusCode}');
        print('Device State API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
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
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => 'HttpException: $message';
}

