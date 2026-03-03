import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../api/api_config.dart';
import 'storage_service.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static StreamSubscription? _subscription;
  static final Map<String, StreamController<Map<String, dynamic>>> _topicControllers = {};
  static bool _isConnected = false;
  static Timer? _heartbeatTimer;
  static Timer? _reconnectTimer;
  static int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // WebSocket connection URL
  static String get _wsUrl {
    final baseUrl = ApiConfig.baseUrl;
    final wsUrl = baseUrl.replaceFirst('http', 'ws');
    return '$wsUrl/messaging';
  }

  /// Connect to WebSocket server
  static Future<bool> connect() async {
    try {
      if (_isConnected && _channel != null) {
        //print('WebSocket: Already connected');
        return true;
      }

      final token = await StorageService.getToken();
      if (token == null) {
        //print('WebSocket: No token available');
        return false;
      }

      //print('WebSocket: Connecting to $_wsUrl');
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl/$token'),
      );

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      //_startHeartbeat();

      //print('WebSocket: Connected successfully');
      return true;
    } catch (e) {
      print('WebSocket: Connection failed: $e');
      _scheduleReconnect();
      return false;
    }
  }

  /// Disconnect from WebSocket server
  static Future<void> disconnect() async {
    //_stopHeartbeat();
    _stopReconnectTimer();

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close(status.normalClosure);
    _channel = null;

    _isConnected = false;

    // Close all topic controllers
    for (var controller in _topicControllers.values) {
      await controller.close();
    }
    _topicControllers.clear();

    //print('WebSocket: Disconnected');
  }

  /// Subscribe to a device state topic
  static Stream<Map<String, dynamic>> subscribe(String id, String topic, {Map<String, dynamic>? parameter}) {
    // Create or get existing stream controller for this topic
    if (!_topicControllers.containsKey(topic)) {
      _topicControllers[topic] = StreamController<Map<String, dynamic>>.broadcast();
      //print('WebSocket: Created controller for topic: $topic');
    }

    print('WebSocket: Current registered topics: ${_topicControllers.keys.toList()}');

    // Send subscription message if connected
    if (_isConnected && _channel != null) {
      //print('WebSocket: Sending subscription for topic: $topic');
      _sendSubscriptionMessage(
        'sub',
        id,
        topic,
        parameter: parameter,
      );
    } else {
      //print('WebSocket: Not connected, will connect and subscribe to topic: $topic');
      // Try to connect and then subscribe
      connect().then((success) {
        if (success) {
          //print('WebSocket: Connected successfully, sending subscription for topic: $topic');
          _sendSubscriptionMessage(
            'sub',
            id,
            topic,
            parameter: parameter,
          );
        }
      });
    }

    return _topicControllers[topic]!.stream;
  }

  /// Unsubscribe from a device state topic
  static void unsubscribe(String id, String topic) {
    //print('WebSocket: Unsubscribing from topic: $topic, id: $id');

    if (_isConnected && _channel != null) {
      _sendSubscriptionMessage(
        'unsub',
        id,
        topic,
      );
    }

    // Close and remove the stream controller
    if (_topicControllers.containsKey(topic)) {
      _topicControllers[topic]!.close();
      _topicControllers.remove(topic);
      //print('WebSocket: Removed controller for topic: $topic');
    }
  }

  /// Send subscription/unsubscription message
  static void _sendSubscriptionMessage(String type, String id, String topic, {Map<String, dynamic>? parameter}) {
    final message = {
      'type': type,
      'id': id,
      'topic': topic,
      'parameter': parameter ?? {},
    };

    try {
      final jsonMessage = jsonEncode(message);
      //print('WebSocket: Sending $type message: $jsonMessage');
      _channel?.sink.add(jsonMessage);
      //print('WebSocket: Successfully sent message for topic: $topic with id: $id');
    } catch (e) {
      print('WebSocket: Failed to send message: $e');
    }
  }

  /// Handle incoming WebSocket messages
  static void _onMessage(dynamic data) {
    try {
      //print('WebSocket: Raw message received: $data');
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      final type = message['type'] as String?;
      final topic = message['topic'] as String?;

      if (type == 'result' && topic != null) {
        // This is a subscription result message with actual data
        //print('WebSocket: Processing result message for topic: $topic');
        if (_topicControllers.containsKey(topic)) {
          //print('WebSocket: Forwarding result to topic controller: $topic');
          _topicControllers[topic]!.add(message);
        }
      } else if (type == 'message' && topic != null) {
        // Handle regular message type
        //print('WebSocket: Processing message for topic: $topic');
        if (_topicControllers.containsKey(topic)) {
          //print('WebSocket: Forwarding message to topic controller: $topic');
          _topicControllers[topic]!.add(message);
        }
      } else if (type == 'pong') {
        // Handle heartbeat response
        //print('WebSocket: Received pong');
      } else if (type == 'sub' || type == 'unsub') {
        // Handle subscription confirmation
        //print('WebSocket: Subscription confirmation - type: $type, topic: $topic');
      }
    } catch (e) {
      print('WebSocket: Failed to parse message: $e');
      print('WebSocket: Raw data: $data');
    }
  }

  /// Handle WebSocket errors
  static void _onError(error) {
    //print('WebSocket: Error occurred: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  static void _onDisconnected() {
    //print('WebSocket: Connection closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Start heartbeat timer
  static void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected && _channel != null) {
        try {
          final ping = {
            'type': 'ping',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          _channel!.sink.add(jsonEncode(ping));
        } catch (e) {
          print('WebSocket: Failed to send ping: $e');
        }
      }
    });
  }

  /// Stop heartbeat timer
  static void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedule reconnection attempt
  static void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('WebSocket: Max reconnection attempts reached');
      return;
    }

    _stopReconnectTimer();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      print('WebSocket: Reconnection attempt $_reconnectAttempts');
      connect();
    });
  }

  /// Stop reconnection timer
  static void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Check if WebSocket is connected
  static bool get isConnected => _isConnected;

  /// Get connection status
  static String get connectionStatus {
    if (_isConnected) {
      return 'Connected';
    } else if (_reconnectTimer?.isActive == true) {
      return 'Reconnecting...';
    } else {
      return 'Disconnected';
    }
  }
}