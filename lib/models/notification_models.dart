class NotificationItem {
  final int id;
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'],
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
