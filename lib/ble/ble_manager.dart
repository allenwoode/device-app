import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// 蓝牙管理类
class BluetoothManager {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;
  StreamSubscription? notificationSubscription;

  Future<List<BluetoothDevice>> scanForDevices(String platformName, {Duration timeout = const Duration(seconds: 15)}) async {
    List<BluetoothDevice> devices = [];
    Set<String> foundDeviceIds = {};

    // 检查蓝牙是否支持
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('ble unsupport!');
    }

    // 先停止之前的扫描
    await FlutterBluePlus.stopScan();

    // 订阅扫描结果
    var subscription = FlutterBluePlus.scanResults.listen((results) async {

      for (ScanResult r in results) {
        String deviceId = r.device.remoteId.toString();
        String name = r.device.platformName;
        //String localName = r.device.advName;
        //int rssi = r.rssi;
        
        // 避免重复添加
        if (foundDeviceIds.contains(deviceId)) continue;
        foundDeviceIds.add(deviceId);
      
        
        // 检查是否包含（不区分大小写）
        bool found = name == platformName;
        
        if (found) {
          devices.add(r.device);
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
    await FlutterBluePlus.stopScan();

    await subscription.cancel();
    
    return devices;
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
        if (service.uuid.str == 'fee7') {
          for (var characteristic in service.characteristics) {

            if (characteristic.uuid.str == 'fec7') {
              writeCharacteristic = characteristic;
            }

            if (characteristic.uuid.str == 'fec8') {
              notifyCharacteristic = characteristic;
            }
          }
        }
      }
    
      if (writeCharacteristic == null || notifyCharacteristic == null) {
        throw Exception('Required characteristics not found');
      }

      // Enable notifications
      await notifyCharacteristic!.setNotifyValue(true);

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

  /// 断开连接
  Future<void> disconnect() async {
    await notificationSubscription?.cancel();
    await connectedDevice?.disconnect();
    connectedDevice = null;
    writeCharacteristic = null;
    notifyCharacteristic = null;
  }

  /// 发送数据并等待响应
  Future<void> sendData(Uint8List data) async {
    if (writeCharacteristic == null) {
      throw Exception('write characteristic no found');
    }

    // 执行写入
    await writeCharacteristic!.write(data);
  }
}