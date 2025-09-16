import 'dart:convert';

class DeviceData {
  final String id;
  final int state;
  final String name;
  final String productId;
  final String productName;
  final String description;
  final String extraData;
  final String lastUpdated;

  DeviceData({
    required this.id,
    required this.state,
    required this.name,
    required this.productId,
    required this.productName,
    required this.description,
    required this.extraData,
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
      extraData: json['extraData'],
      lastUpdated: json['createTime']?.toString() ?? json['lastUpdated'] ?? '',
    );
  }
}

class ExtraData {
  final int chargeNum;
  final int gateNum;
  final String organization;
  final String power;

  ExtraData({
    required this.chargeNum,
    required this.gateNum,
    required this.organization,
    required this.power,
  });

  factory ExtraData.decode(String str) {
    Map<String, dynamic> obj = jsonDecode(str);
    return ExtraData(chargeNum: obj['charge_num'], gateNum: obj['gate_num'], organization: obj['organization'], power: obj['power']);
  }
}

class DashboardDevices {
  final int total;
  final int onlineCount;
  final int offlineCount;

  DashboardDevices({
    required this.total,
    required this.onlineCount,
    required this.offlineCount,
  });

  factory DashboardDevices.fromJson(Map<String, dynamic> json) {
    return DashboardDevices(
      total: json['total'] ?? 0,
      onlineCount: json['onlineCount'] ?? 0,
      offlineCount: json['offlineCount'] ?? 0,
    );
  }
}

class DashboardUsage {
  final String label;
  final int value;
  final String text;

  DashboardUsage({
    required this.label,
    required this.value,
    required this.text,
  });

  factory DashboardUsage.fromJson(Map<String, dynamic> json) {
    return DashboardUsage(
      label: json['label'] ?? '',
      value: json['value'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}

class DashboardAlerts {
  final int total;
  final int alarmCount;
  final int severeCount;

  DashboardAlerts({
    required this.total,
    required this.alarmCount,
    required this.severeCount,
  });

  factory DashboardAlerts.fromJson(Map<String, dynamic> json) {
    return DashboardAlerts(
      total: json['total'] ?? 0,
      alarmCount: json['alarmCount'] ?? 0,
      severeCount: json['severeCount'] ?? 0,
    );
  }
}

class DashboardMessage {
  final int total;
  final int reportCount;
  final int functionCount;

  DashboardMessage({
    required this.total,
    required this.reportCount,
    required this.functionCount,
  });

  factory DashboardMessage.fromJson(Map<String, dynamic> json) {
    return DashboardMessage(
      total: json['total'] ?? 0,
      reportCount: json['reportCount'] ?? 0,
      functionCount: json['functionCount'] ?? 0,
    );
  }
}