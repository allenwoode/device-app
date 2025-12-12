class EventBus {
  // 私有构造器
  EventBus._internal();

  static EventBus? _instance;

  static EventBus get instance => _getInstance();

  static EventBus _getInstance() {
    return _instance ??= EventBus._internal();
  }

  // 存储事件回调方法 - 支持多个监听器
  final Map<String, List<Function>> _events = {};

  // 设置事件监听
  void addListener(String eventKey, Function callback) {
    if (!_events.containsKey(eventKey)) {
      _events[eventKey] = [];
    }
    _events[eventKey]!.add(callback);
  }

  // 移除监听
  void removeListener(String eventKey, Function callback) {
    _events[eventKey]?.remove(callback);
    if (_events[eventKey]?.isEmpty ?? false) {
      _events.remove(eventKey);
    }
  }

  // 提交事件 - 通知所有监听器
  void commit(String eventKey, [dynamic data]) {
    final listeners = _events[eventKey];
    if (listeners != null) {
      // 创建副本以避免在迭代过程中修改列表
      for (var callback in List.from(listeners)) {
        try {
          if (data != null) {
            callback(data);
          } else {
            callback();
          }
        } catch (e) {
          print('Error in event listener for $eventKey: $e');
        }
      }
    }
  }

  // 清除所有监听器
  void clear() {
    _events.clear();
  }

  // 清除特定事件的所有监听器
  void clearEvent(String eventKey) {
    _events.remove(eventKey);
  }
}

class EventKeys {
  static const String logout = "Logout";
  static const String notificationReceived = "NotificationReceived";
  static const String notificationCountChanged = "NotificationCountChanged";
}
