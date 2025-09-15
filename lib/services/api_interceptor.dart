import 'dart:convert';
import 'package:http/http.dart' as http;
import 'event_bus_service.dart';
import '../events/auth_events.dart';
import 'storage_service.dart';

class ApiInterceptor {
  static Future<http.Response> request({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    http.Response response;
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      // Check for 401 status code
      if (response.statusCode == 401) {

        // Clear local storage
        await StorageService.clearAll();
        
        // Fire unauthorized event
        EventBusService.fire(UnauthorizedEvent('Authentication expired'));
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return request(method: 'GET', url: url, headers: headers);
  }
  
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, dynamic body}) {
    return request(method: 'POST', url: url, headers: headers, body: body);
  }
  
  static Future<http.Response> put(Uri url, {Map<String, String>? headers, dynamic body}) {
    return request(method: 'PUT', url: url, headers: headers, body: body);
  }
  
  static Future<http.Response> delete(Uri url, {Map<String, String>? headers}) {
    return request(method: 'DELETE', url: url, headers: headers);
  }
}