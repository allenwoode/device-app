import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// 蓝牙管理类
class BluetoothManager {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;
  StreamSubscription? notificationSubscription;

  bool writeWithoutResponse = false; // Track which write type to use

  Future<List<BluetoothDevice>> scanForDevices({Duration timeout = const Duration(seconds: 15)}) async {
    List<BluetoothDevice> azDevices = [];
    Set<String> foundDeviceIds = {};

    // 检查蓝牙是否支持
    if (await FlutterBluePlus.isSupported == false) {
      print("蓝牙不支持");
      return azDevices;
    }

    // 检查蓝牙是否开启
    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      print("蓝牙未开启，请先开启蓝牙");
      return azDevices;
    }

    // 先停止之前的扫描
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('停止扫描异常: $e');
    }

    // 订阅扫描结果
    var subscription = FlutterBluePlus.scanResults.listen((results) async {

      for (ScanResult r in results) {
        String deviceId = r.device.remoteId.toString();
        String platformName = r.device.platformName;
        //String localName = r.device.advName;
        //int rssi = r.rssi;
        
        // 避免重复添加
        if (foundDeviceIds.contains(deviceId)) continue;
        foundDeviceIds.add(deviceId);
      
        
        // 检查是否包含 'AZ'（不区分大小写）
        bool isAZDevice = platformName == 'AZ';
        
        if (isAZDevice) {
          azDevices.add(r.device);
          await FlutterBluePlus.startScan();
          break;
        }
      }
    });

    // 开始扫描（关闭过滤，扫描所有设备）
    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );

    // 等待找到设备或超时
    int elapsed = 0;
    while (elapsed < timeout.inSeconds * 1000) {
      await Future.delayed(Duration(milliseconds: 100));
      elapsed += 100;
    }

    // 停止扫描
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('停止扫描异常: $e');
    }
    await subscription.cancel();
    
    return azDevices;
  }

  /// 连接到指定设备
  Future<bool> connectToDevice(BluetoothDevice device, Function received) async {
    try {
      print('正在连接到: ${device.platformName}: (${device.remoteId})');
      await device.connect(timeout: Duration(seconds: 15));
      connectedDevice = device;
      
      print('连接成功，正在发现服务...');
      List<BluetoothService> services = await device.discoverServices();
      
      for (var service in services) {
        print('服务 UUID: ${service.uuid}');
        if (service.uuid.str == 'fee7') {
          for (var characteristic in service.characteristics) {
            print('  特征 UUID: ${characteristic.uuid}');
            print('  属性: Write=${characteristic.properties.write}, Read=${characteristic.properties.read}, '
                'Notify=${characteristic.properties.notify}, '
                'WriteNoResponse=${characteristic.properties.writeWithoutResponse}');

            // Select write characteristic: Write=true, Notify=false, WriteNoResponse=false
            if (characteristic.uuid.str == 'fec7') {
              writeCharacteristic = characteristic;
              print('  -> 设置为写入特征 (Write=true)');
            }

            // Select notify characteristic: Notify=true
            if (characteristic.uuid.str == 'fec8') {
              notifyCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              print('  -> 设置为通知特征 (Notify=true)');
            }
          }
        }
      }
    
      if (writeCharacteristic == null || notifyCharacteristic == null) {
        throw Exception('Required characteristics not found');
      }

      // Enable notifications
      await notifyCharacteristic!.setNotifyValue(true);
      print('Notifications enabled');

      // Subscribe to notifications
      notificationSubscription = notifyCharacteristic!.lastValueStream.listen((data) {
        received(Uint8List.fromList(data));
      });
      
      return true;
    } catch (e) {
      print('连接失败: $e');
      return false;
    }
  }

  // 取消监听
  Future<void> cancel() async {
    await notificationSubscription?.cancel();
  }

  /// 断开连接
  Future<void> disconnect() async {
    await notificationSubscription?.cancel();
    await connectedDevice?.disconnect();
    connectedDevice = null;
    writeCharacteristic = null;
    notifyCharacteristic = null;
    writeWithoutResponse = false;
  }

  /// 发送数据并等待响应
  Future<Map<String, dynamic>> sendData(Uint8List data, {Function(String)? onLog}) async {
    if (writeCharacteristic == null) {
      print('错误: 写入特征未找到');
      onLog?.call('错误: 写入特征未找到');
      return {'success': false, 'error': '写入特征未找到'};
    }

    try {
      String writeType = writeWithoutResponse ? 'without response' : 'with response';
      String dataHex = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      print('发送数据 (${data.length} 字节, $writeType): $dataHex');
      onLog?.call('写入 ${data.length} 字节 ($writeType)');

      // 如果有通知特征，设置临时监听以捕获响应
      List<int>? response;
      var responseCompleter = Completer<List<int>?>();
      var subscription;

      if (notifyCharacteristic != null) {
        subscription = notifyCharacteristic!.lastValueStream.listen((data) {
          if (!responseCompleter.isCompleted) {
            responseCompleter.complete(data);
          }
        });

        // 设置超时
        Future.delayed(Duration(milliseconds: 500), () {
          if (!responseCompleter.isCompleted) {
            responseCompleter.complete(null);
          }
        });
      }

      // 执行写入
      await writeCharacteristic!.write(data, withoutResponse: writeWithoutResponse);

      // 等待响应（如果有通知特征）
      if (notifyCharacteristic != null) {
        response = await responseCompleter.future;
        await subscription?.cancel();

        if (response != null) {
          String responseHex = response.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
          print('收到响应: $responseHex');
          onLog?.call('响应: $responseHex');
          return {'success': true, 'response': response, 'responseHex': responseHex};
        }
      }

      // Write with response 的 ACK
      if (!writeWithoutResponse) {
        onLog?.call('写入响应: ACK 成功');
      }

      return {'success': true};
    } catch (e) {
      print('发送数据失败: $e');
      onLog?.call('发送失败: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 监听数据接收
  Stream<List<int>>? listenToNotifications() {
    return notifyCharacteristic?.lastValueStream;
  }
}