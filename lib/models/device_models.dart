class DeviceData {
  final String id;
  final int state;
  final String name;
  final String productId;
  final String productName;
  final String description;
  final String lastUpdated;

  DeviceData({
    required this.id,
    required this.state,
    required this.name,
    required this.productId,
    required this.productName,
    required this.description,
    required this.lastUpdated,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      id: json['id'] ?? json['deviceId'] ?? '',
      state: json['state']?['value'] == 'online' ? 1 : 0,
      name: json['name'] ?? json['deviceName'] ?? '',
      productId: json['productId'],
      productName: json['productName'] ?? json['productName'] ?? '',
      description: json['description'] ?? json['description'] ?? '',
      lastUpdated: json['createTime']?.toString() ?? json['lastUpdated'] ?? '',
    );
  }
}