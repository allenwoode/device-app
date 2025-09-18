import 'dart:convert';

class DeviceData {
  final String id;
  final int state;
  final String name;
  final String productId;
  final String productName;
  final String description;
  final ExtraData extraData;
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
      id: json['id'] ?? '',
      state: json['state']?['value'] == 'online' ? 1 : 0,
      name: json['name'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      extraData: ExtraData.decode(json['extraData'] ?? {}),
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

class DeviceUsage {
  final int port;
  final String type;
  final int timestamp;
  final String typeFormat;
  final String portFormat;
  final int timestampFormat;
  final String deviceId;
  final String depo;
  final String depoFormat;
  final String createTime;

  DeviceUsage({
    required this.port,
    required this.type,
    required this.timestamp,
    required this.typeFormat,
    required this.portFormat,
    required this.timestampFormat,
    required this.deviceId,
    required this.depo,
    required this.depoFormat,
    required this.createTime,
  });

  factory DeviceUsage.fromJson(Map<String, dynamic> json) {
    return DeviceUsage(
      port: json['port'] ?? 0,
      type: json['type'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      typeFormat: json['type_format'] ?? '',
      portFormat: json['port_format'] ?? '',
      timestampFormat: json['timestamp_format'] ?? 0,
      deviceId: json['deviceId'] ?? '',
      depo: json['depo'] ?? '',
      depoFormat: json['depo_format'] ?? '',
      createTime: json['createTime'] ?? '',
    );
  }
}

class DeviceAlert {
  final int level;
  final String levelFormat;
  final String text;
  final String createTime;
  final String deviceId;
  final int port;
  final int timestamp;

  DeviceAlert({
    required this.level,
    required this.levelFormat,
    required this.text,
    required this.createTime,
    required this.deviceId,
    required this.port,
    required this.timestamp,
  });

  factory DeviceAlert.fromJson(Map<String, dynamic> json) {
    return DeviceAlert(
      level: json['level'] ?? 0,
      levelFormat: json['level_format'] ?? '',
      text: json['text'] ?? '',
      createTime: json['createTime'] ?? '',
      deviceId: json['deviceId'] ?? '',
      port: json['port'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }

  String get alertInfo => port > 0 ? 'C$port $text' : text;
}

class DeviceLog {
  final String category;
  final String text;
  final String createTime;
  final String deviceId;
  final int timestamp;

  DeviceLog({
    required this.category,
    required this.text,
    required this.createTime,
    required this.deviceId,
    required this.timestamp,
  });

  factory DeviceLog.fromJson(Map<String, dynamic> json) {
    return DeviceLog(
      category: json['category'] ?? '',
      text: json['text'] ?? '',
      createTime: json['createTime'] ?? '',
      deviceId: json['deviceId'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  String get logInfo => '[$category] $text';
}

class DeviceAlertResponse {
  final String message;
  final DeviceAlertResult result;
  final int status;
  final int timestamp;

  DeviceAlertResponse({
    required this.message,
    required this.result,
    required this.status,
    required this.timestamp,
  });

  factory DeviceAlertResponse.fromJson(Map<String, dynamic> json) {
    return DeviceAlertResponse(
      message: json['message'] ?? '',
      result: DeviceAlertResult.fromJson(json['result'] ?? {}),
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class DeviceAlertResult {
  final int pageIndex;
  final int pageSize;
  final int total;
  final List<DeviceAlert> data;

  DeviceAlertResult({
    required this.pageIndex,
    required this.pageSize,
    required this.total,
    required this.data,
  });

  factory DeviceAlertResult.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = json['data'] ?? [];
    List<DeviceAlert> alertList = dataList.map((item) => DeviceAlert.fromJson(item)).toList();

    return DeviceAlertResult(
      pageIndex: json['pageIndex'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      total: json['total'] ?? 0,
      data: alertList,
    );
  }
}

class DeviceUsageResponse {
  final String message;
  final DeviceUsageResult result;
  final int status;
  final int timestamp;

  DeviceUsageResponse({
    required this.message,
    required this.result,
    required this.status,
    required this.timestamp,
  });

  factory DeviceUsageResponse.fromJson(Map<String, dynamic> json) {
    return DeviceUsageResponse(
      message: json['message'] ?? '',
      result: DeviceUsageResult.fromJson(json['result'] ?? {}),
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class DeviceUsageResult {
  final int pageIndex;
  final int pageSize;
  final int total;
  final List<DeviceUsage> data;

  DeviceUsageResult({
    required this.pageIndex,
    required this.pageSize,
    required this.total,
    required this.data,
  });

  factory DeviceUsageResult.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = json['data'] ?? [];
    List<DeviceUsage> usageList = dataList.map((item) => DeviceUsage.fromJson(item)).toList();

    return DeviceUsageResult(
      pageIndex: json['pageIndex'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      total: json['total'] ?? 0,
      data: usageList,
    );
  }
}