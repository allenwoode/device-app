import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'api_config.dart';

class DeviceApi {
  
  static Future<Map<String, dynamic>> getDevices() async {
    try {
      // First try to fetch from API
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.devicesEndpoint}');
      // Prepare request body for POST request
      final requestBody = json.encode({
        'pageIndex': 0,
        'pageSize': 5,
        // Add any other required parameters here
        'sort': [
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
      });
      
      final response = await http.post(
        uri,
        headers: ApiConfig.defaultHeaders,
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
          // API returns: { "result": { "data": [...] } }
          if (responseData.containsKey('result') && 
              responseData['result'] is Map<String, dynamic> &&
              responseData['result'].containsKey('data')) {
            return {'devices': responseData['result']['data']};
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
        return {'devices': []};;
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
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => 'HttpException: $message';
}