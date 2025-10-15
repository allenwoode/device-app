import 'dart:convert';
import 'dart:typed_data';

import 'package:device/ble/ble_manager.dart';
import 'package:device/ble/frame_createor.dart';
import 'package:device/ble/response.dart';
import 'package:device/ble/tea.dart';
import 'package:device/l10n/app_localizations.dart';
import 'package:device/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class DeviceConnectorPage extends StatefulWidget {
  const DeviceConnectorPage({super.key});

  @override
  State<DeviceConnectorPage> createState() => _DeviceConnectorPageState();
}

class _DeviceConnectorPageState extends State<DeviceConnectorPage> {
  static const String TEA_ENCRYPTION_KEY = "hiflying12345678";
  static const String BLE_CONFIG_ACK = "config_ack";

  final BluetoothManager btManager = BluetoothManager();
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<BluetoothDevice> foundDevices = [];
  BluetoothDevice? selectedDevice;
  bool isScanning = false;
  bool isConnected = false;
  bool obscurePassword = true;
  String statusMessage = '准备就绪';
  List<String> logs = [];

  final TeaEncryptor _encryptor = TeaEncryptor(TEA_ENCRYPTION_KEY);
  final BleDeviceResponseFrames _responseFrames = BleDeviceResponseFrames();

  final StreamController<String> _statusController = StreamController<String>.broadcast();
  Stream<String> get statusStream => _statusController.stream;

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  @override
  void initState() {
    super.initState();

    _scanCurrentWifiSsid();
  }

  Future<void> _scanCurrentWifiSsid() async {
    // Try to get current WiFi SSID
    String? currentSSID;

    try {
      // Request location permission if needed
      if (await Permission.location.isDenied) {
        await Permission.location.request();
      }

      if (await Permission.location.isGranted) {
        final networkInfo = NetworkInfo();
        currentSSID = await networkInfo.getWifiName();

        // Remove quotes if present (iOS adds quotes around SSID)
        if (currentSSID != null) {
          currentSSID = currentSSID.replaceAll('"', '');
        }
      }
    } catch (e) {
      // Ignore errors, just won't pre-fill SSID
    }

    // Set the current SSID as default value
    if (currentSSID != null && currentSSID.isNotEmpty) {
      ssidController.text = currentSSID;
      final String? password = await StorageService.getWifiConfig(currentSSID);
      if (password!.isNotEmpty) {
        passwordController.text = password;
      }
    }
  }

  void _addLog(String message) {
    setState(() {
      logs.insert(0, '${DateTime.now().toString().substring(11, 19)} - $message');
      if (logs.length > 20) logs.removeLast();
    });
  }

  /// 扫描 AZ 设备
  Future<void> scanForDevices() async {
    setState(() {
      isScanning = true;
      foundDevices.clear();
      statusMessage = '正在扫描 AZ 设备...';
    });
    _addLog('开始扫描平台名包含 "AZ" 的设备');

    try {
      List<BluetoothDevice> devices = await btManager.scanForDevices(
        timeout: Duration(seconds: 10)
      );

      setState(() {
        foundDevices = devices;
        isScanning = false;
        statusMessage = '找到 ${devices.length} 个 AZ 设备';
      });
      _addLog('扫描完成，找到 ${devices.length} 个设备');
      
      if (devices.isEmpty) {
        _addLog('未找到 AZ 设备，请确保设备已开启');
      }
    } catch (e) {
      setState(() {
        isScanning = false;
        statusMessage = '扫描失败';
      });
      _addLog('扫描错误: $e');
    }
  }

  /// 连接设备
  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() => statusMessage = '正在连接...');
    _addLog('尝试连接到: ${device.platformName}');

    bool success = await btManager.connectToDevice(device, _onNotificationReceived);
    
    setState(() {
      isConnected = success;
      selectedDevice = success ? device : null;
      statusMessage = success ? '已连接到 ${device.platformName}' : '连接失败';
    });
    
    if (success) {
      _addLog('连接成功');
    } else {
      _addLog('连接失败');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    await btManager.cancel();
    await btManager.disconnect();
    setState(() {
      isConnected = false;
      selectedDevice = null;
      foundDevices = [];
      statusMessage = '已断开连接';
    });
    _addLog('断开连接');
  }

  /// 发送 WiFi 配置
  Future<void> sendWiFiConfig() async {
    if (!isConnected) {
      _addLog('错误: 请先连接设备');
      return;
    }

    final ssid = ssidController.text.trim();
    final password = passwordController.text.trim();

    if (ssid.isEmpty) {
      _addLog('错误: 请输入 WiFi SSID');
      return;
    }

    setState(() => statusMessage = '发送配置中...');
    _addLog('=== 开始发送 WiFi 配置 ===');
    _addLog('SSID: $ssid');
    _addLog('密码长度: ${password.length}');

    try {
      await link(ssid, password);
      setState(() => statusMessage = '发送配置成功');
      StorageService.saveWifiConfig(ssid, password);
    } catch (e) {
      _addLog('发送配置失败');
    } finally {
      await disconnect();
    }
  }

  Future<void> link(String ssid, String password) async {
      await sendConfigFrames(ssid, password);

      await sendConfigAck();

      await waitForDeviceResponse();
  }

  Future<bool> sendConfigFrames(String ssid, String password, {Duration timeout = const Duration(seconds: 10)}) async {
    try {
      final frames = LinkingRequestFrameCreator.createConfigFrames(
        _encryptor,
        ssid,
        password,
        '',
      );

      // Wait for config_success or config_fail
      final completer = Completer<bool>();
      late StreamSubscription subscription;

      subscription = _statusController.stream.listen((status) {
        if (status == 'config_success') {
          subscription.cancel();
          completer.complete(true);
        } else if (status == 'config_fail') {
          subscription.cancel();
          completer.complete(false);
        }
      });

      // Send frames with retry logic
      bool keepSending = true;
      Future.delayed(timeout, () {
        keepSending = false;
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.complete(false);
        }
      });

      while (keepSending && !completer.isCompleted) {
        for (int i = 0; i < frames.length && keepSending; i++) {
          await btManager.sendData(frames[i]);

          await Future.delayed(const Duration(milliseconds: 500));

          if (completer.isCompleted) {
            keepSending = false;
            break;
          }
        }
      }

      return await completer.future;
    } catch (e) {
      print('Send config error: $e');
      throw Exception('send config failed');
    }
  }

  Future<bool> sendConfigAck({int retries = 6}) async {
    try {
      for (int i = 0; i < retries; i++) {
        await btManager.sendData(
          Uint8List.fromList(utf8.encode(BLE_CONFIG_ACK)),
        );

        await Future.delayed(const Duration(milliseconds: 500));
      }

      return true;
    } catch (e) {
      print('Send ACK error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> waitForDeviceResponse({Duration timeout = const Duration(seconds: 30)}) async {
    _addLog('=== 等待设备响应 ===');
    final completer = Completer<Map<String, dynamic>?>();

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        _addLog('设备响应超时，请检查WIFI密码是否正确');
        completer.complete(null);
      }
    });

    // The response will come via notifications
    // When frames are complete, they'll be parsed in _onNotificationReceived
    late StreamSubscription subscription;
    subscription = _statusController.stream.listen((status) {
      if (status.startsWith('device_response:')) {
        final jsonStr = status.substring('device_response:'.length);
        try {
          final response = json.decode(jsonStr) as Map<String, dynamic>;
          subscription.cancel();
          completer.complete(response);
        } catch (e) {
          print('Failed to parse device response: $e');
          subscription.cancel();
          completer.complete(null);
        }
      }
    });

    return await completer.future;
  }

  /// Handle incoming notifications
  void _onNotificationReceived(Uint8List data) {
    // Try to interpret as text first
    try {
      final text = String.fromCharCodes(data).trim();
      _addLog('收到通知: $text');

      // Check for config success/fail
      if (text.toLowerCase() == 'config_success') {
        _addLog('✓ 设备已接受配置');
        _statusController.add('config_success');
        return;
      } else if (text.toLowerCase() == 'config_fail') {
        _addLog('✗ 设备拒绝配置');
        _statusController.add('config_fail');
        return;
      }
    } catch (e) {
      // Not valid text, might be binary data
      print('ACK text error: $e');
    }

    // Check if this looks like a valid frame (must have at least 3 bytes header)
    if (data.length >= 3) {
      final frameNumber = data[0];
      final totalFrames = data[1];
      final dataLength = data[2];

      // Validate frame structure
      if (frameNumber > 0 && frameNumber <= totalFrames &&
          totalFrames > 0 && totalFrames < 100 &&
          dataLength == data.length - 3) {
        _addLog('接收帧 $frameNumber/$totalFrames');

        try {
          _responseFrames.addFrame(data);

          if (_responseFrames.isCompleted) {
            final decrypted = _responseFrames.unpackAndDecryptFrames(_encryptor);
            final jsonStr = utf8.decode(decrypted, allowMalformed: true).trim();
            _addLog('设备响应: $jsonStr');
            _statusController.add('device_response:$jsonStr');
          }
        } catch (e) {
          _addLog('帧处理错误: $e');
        }
      } else {
        _addLog('未知数据格式');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: Colors.black,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _l10n.deviceConnector,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态显示
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // 扫描和设备列表
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isScanning ? null : scanForDevices,
                    icon: Icon(Icons.search),
                    label: Text(isScanning ? '扫描中...' : '扫描 AZ 设备'),
                  ),
                ),
                if (isConnected) ...[
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: disconnect,
                    icon: Icon(Icons.bluetooth_disabled),
                    label: Text('断开'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
                  ),
                ],
              ],
            ),
            
            if (foundDevices.isNotEmpty) ...[
              SizedBox(height: 12),
              Text('找到的 AZ 设备:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: foundDevices.length,
                  itemBuilder: (context, index) {
                    var device = foundDevices[index];
                    bool isSelected = selectedDevice?.remoteId == device.remoteId;
                    return ListTile(
                      title: Text(device.platformName),
                      subtitle: Text(device.remoteId.toString()),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.arrow_forward_ios, size: 16),
                      selected: isSelected,
                      onTap: () => connectToDevice(device),
                    );
                  },
                ),
              ),
            ],

            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),

            // WiFi 配置表单
            Text('WiFi 配置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: ssidController,
              decoration: InputDecoration(
                labelText: 'WiFi SSID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                    labelText: 'WiFi Password',
                    hintText: 'Enter WiFi password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isConnected ? sendWiFiConfig : null,
              icon: Icon(Icons.send),
              label: Text('发送配置'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 10),
            Divider(),
            
            // 日志显示
            Text('日志:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        logs[index],
                        style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    btManager.disconnect();
    _statusController.close();
    super.dispose();
  }

}