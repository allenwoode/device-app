import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device/ble/ble_manager.dart';
import 'package:device/ble/frame_createor.dart';
import 'package:device/ble/response.dart';
import 'package:device/ble/tea.dart';
import 'package:device/config/app_colors.dart';
import 'package:device/l10n/app_localizations.dart';
import 'package:device/services/storage_service.dart';
import 'package:device/widgets/confirm_dialog.dart';
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
  bool isConnecting = false;
  bool isConnected = false;
  bool isSending = false;
  bool obscurePassword = true;
  String statusMessage = '';
  List<String> logs = [];

  final TeaEncryptor _encryptor = TeaEncryptor(TEA_ENCRYPTION_KEY);
  final BleDeviceResponseFrames _responseFrames = BleDeviceResponseFrames();

  final StreamController<String> _statusController = StreamController<String>.broadcast();
  //Stream<String> get statusStream => _statusController.stream;
  StreamSubscription? stateSubscription;
  bool bleOff = false;

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
    _checkBluetoothState();
    _getCurrentSsid();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial status message after context is available
    if (statusMessage.isEmpty) {
      setState(() {
        statusMessage = _l10n.ready;
      });
    }
  }

  Future<void> _checkBluetoothState() async {
    stateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        if (state != BluetoothAdapterState.on) {
          setState(() {
            statusMessage = _l10n.pleaseEnableBluetooth;
            bleOff = true;
          });
          _addLog(_l10n.bluetoothNotEnabled);
        } else {
          setState(() {
            statusMessage = _l10n.ready;
            bleOff = false;
          });
        }
    });
  }

  Future<void> _getCurrentSsid() async {
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

  Future<bool> turnOn() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
      return true;
    }
    return false;
  }

  /// 扫描 AZ 设备
  Future<void> scanForDevices() async {
    if (bleOff) {
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: _l10n.bluetoothRequired,
        message: _l10n.bluetoothRequiredMessage,
        confirmText: _l10n.turnOn,
        cancelText: _l10n.cancel,
      );

      if (confirmed == true) {
        await turnOn();
      } else {
        return;
      }
    }

    setState(() {
      isScanning = true;
      foundDevices.clear();
      statusMessage = _l10n.scanningAzDevices;
    });
    _addLog(_l10n.startScanning);

    try {
      List<BluetoothDevice> devices = await btManager.scanForDevices(
        timeout: Duration(seconds: 10)
      );

      setState(() {
        foundDevices = devices;
        isScanning = false;
        statusMessage = _l10n.foundAzDevices(devices.length);
      });
      _addLog(_l10n.scanComplete(devices.length));

      if (devices.isEmpty) {
        _addLog(_l10n.noAzDevices);
      }
    } catch (e) {
      setState(() {
        isScanning = false;
        statusMessage = _l10n.scanError;
      });
      _addLog(_l10n.scanError);
    }
  }

  /// 连接设备
  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() => statusMessage = _l10n.connecting);
    setState(() => isConnecting = true);
    _addLog(_l10n.attemptingConnection(device.platformName));

    bool success = await btManager.connectToDevice(device, _onNotificationReceived);

    setState(() {
      isConnected = success;
      isConnecting = false;
      selectedDevice = success ? device : null;
      statusMessage = success ? _l10n.connectedTo(device.platformName) : _l10n.connectionFailed;
    });

    if (success) {
      _addLog(_l10n.connectionSuccess);
    } else {
      _addLog(_l10n.connectionFailed);
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    await btManager.disconnect();
    setState(() {
      isConnected = false;
      statusMessage = _l10n.disconnected;
      selectedDevice = null;
    });
    _addLog(_l10n.disconnected);
  }

  /// 发送 WiFi 配置
  Future<void> sendWiFiConfig() async {
    if (!isConnected) {
      _addLog(_l10n.errorConnectFirst);
      return;
    }

    final ssid = ssidController.text.trim();
    final password = passwordController.text.trim();

    if (ssid.isEmpty) {
      _addLog(_l10n.errorEnterSsid);
      return;
    }

    setState(() => statusMessage = _l10n.sendingConfig);
    _addLog(_l10n.startSendingWifiConfig);
    _addLog('${_l10n.ssid}: $ssid');
    _addLog('${_l10n.passwordLength}: ${password.length}');

    try {
      setState(() => isSending = true);

      await sendConfigFrames(ssid, password);

      await sendConfigAck();

      await waitForDeviceResponse();

      setState(() => statusMessage = _l10n.configSentSuccess);
      _addLog(_l10n.configSentSuccess);
      StorageService.saveWifiConfig(ssid, password);
    } catch (e) {
      print('send wifi config error: $e');
      setState(() => statusMessage = _l10n.configSentFailed);
      _addLog(_l10n.configSentFailed);
    } finally {
      setState(() => isSending = false);
    }
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

  Future<Map<String, dynamic>?> waitForDeviceResponse({Duration timeout = const Duration(seconds: 10)}) async {
    _addLog(_l10n.waitingForDeviceResponse);
    final completer = Completer<Map<String, dynamic>?>();

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        _addLog(_l10n.deviceResponseTimeout);
        completer.completeError(Exception('device response timeout'));
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
          completer.complete(response);
        } catch (e) {
          print('Failed to parse device response: $e');
          completer.completeError(Exception('Failed to parse device response: $e'));
        } finally {
          subscription.cancel();
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
      _addLog('${_l10n.receivedNotification}: $text');

      // Check for config success/fail
      if (text.toLowerCase() == 'config_success') {
        _addLog(_l10n.deviceAcceptedConfig);
        _statusController.add('config_success');
        return;
      } else if (text.toLowerCase() == 'config_fail') {
        _addLog(_l10n.deviceRejectedConfig);
        _statusController.add('config_fail');
        return;
      }
    } catch (e) {
      // Not valid text, might be binary data
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
        _addLog('${_l10n.receivingFrame} $frameNumber/$totalFrames');

        try {
          _responseFrames.addFrame(data);

          if (_responseFrames.isCompleted) {
            final decrypted = _responseFrames.unpackAndDecryptFrames(_encryptor);
            final jsonStr = utf8.decode(decrypted, allowMalformed: true).trim();
            _addLog('${_l10n.deviceResponse}: $jsonStr');
            _statusController.add('device_response:$jsonStr');
          }
        } catch (e) {
          _addLog('${_l10n.frameProcessingError}: $e');
        }
      } else {
        _addLog(_l10n.unknownDataFormat);
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
                    label: Text(isScanning ? _l10n.scanning : _l10n.scanAzDevices),
                  ),
                ),
                if (isConnected) ...[
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: disconnect,
                    icon: Icon(Icons.bluetooth_disabled, color: Colors.white,),
                    label: Text(_l10n.disconnect, style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[500]),
                  ),
                ],
              ],
            ),
            
            if (foundDevices.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(_l10n.foundAzDevicesLabel, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 70,
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
                      enabled: !isConnecting,
                    );
                  },
                ),
              ),
            ],

            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),

            // WiFi 配置表单
            Text(_l10n.wifiConfig, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: ssidController,
              decoration: InputDecoration(
                labelText: _l10n.wifiSsid,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              enabled: false,
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                    labelText: _l10n.wifiPassword,
                    hintText: _l10n.enterWifiPassword,
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
              onPressed: (isConnected && !isSending) ? sendWiFiConfig : null,
              icon: Icon(Icons.send),
              label: Text(_l10n.sendConfig),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 5),
            Divider(),

            // 日志显示
            Text(_l10n.logs, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
    stateSubscription?.cancel();
    super.dispose();
  }

}