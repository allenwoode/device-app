import 'dart:convert';
import 'package:dio/dio.dart';
import 'event_bus_service.dart';
import '../events/auth_events.dart';
import 'storage_service.dart';

class ApiInterceptor extends Interceptor {
  static final Dio _dio = Dio();
  
  static Dio get dio {
    if (!_dio.interceptors.contains(ApiInterceptor())) {
      _dio.interceptors.add(ApiInterceptor());
    }
    return _dio;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add authorization token if available
    final token = await StorageService.getToken();

    if (token != null) {
      options.headers['x-access-token'] = token;
    }
    
    // Add default content type
    options.headers['Content-Type'] = 'application/json';
    
    print('API Request: ${options.method} ${options.uri}');
    print('Headers: ${options.headers}');
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('API Response: ${response.statusCode} ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('API Error: ${err.response?.statusCode} ${err.requestOptions.uri}');
    
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      print('===========> API Interceptor: 401 Unauthorized - clearing storage and firing event');
      
      // Clear local storage
      await StorageService.clearAll();
      
      // Fire unauthorized event
      EventBusService.fire(UnauthorizedEvent('Authentication expired'));
    }
    
    super.onError(err, handler);
  }
  
  // Static convenience methods for backward compatibility
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }
  
  static Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }
  
  static Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }
  
  static Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }
}