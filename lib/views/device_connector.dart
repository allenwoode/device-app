import 'package:device/config/app_colors.dart';
import 'package:device/l10n/app_localizations.dart';
import 'package:device/models/device_models.dart';
import 'package:device/services/device_service.dart';
import 'package:device/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class DeviceConnectorPage extends StatefulWidget {
  const DeviceConnectorPage({super.key});

  @override
  State<DeviceConnectorPage> createState() => _DeviceConnectorPageState();
}

class _DeviceConnectorPageState extends State<DeviceConnectorPage> {

  final ScrollController _scrollController = ScrollController();

  final Set<String> _selectedDevices = {};
  bool _isUnbinding = false;

  // Bluetooth related state
  List<ScanResult> _bluetoothDevices = [];
  bool _isBluetoothScanning = false;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  List<BluetoothDevice> _connectedBluetoothDevices = [];
  bool _showBluetoothDevices = false;
  
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    _stopBluetoothScan();
    super.dispose();
  }

  void _toggleDeviceSelection(String deviceId) {
    setState(() {
      if (_selectedDevices.contains(deviceId)) {
        _selectedDevices.remove(deviceId);
      } else {
        _selectedDevices.add(deviceId);
      }
    });
  }

  void _selectAllDevices() {
    setState(() {
      _selectedDevices.clear();
      for (final device in _connectedBluetoothDevices) {
        _selectedDevices.add(device.platformName);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDevices.clear();
    });
  }

  void _unbindSelectedDevices() {
    if (_selectedDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _l10n.pleaseSelectAtLeastOneDevice,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    //_showUnbindConfirmDialog();
  }

  // Bluetooth methods
  Future<void> _startBluetoothScan() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bluetooth not supported on this device',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check if Bluetooth is on
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please turn on Bluetooth',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      setState(() {
        _isBluetoothScanning = true;
        _bluetoothDevices.clear();
        _showBluetoothDevices = true;
      });

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      // Listen to scan results
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _bluetoothDevices = results;
          });
        }
      });

      // Listen to scanning state
      _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
        if (mounted) {
          setState(() {
            _isBluetoothScanning = isScanning;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBluetoothScanning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to start Bluetooth scan: $e',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopBluetoothScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      // Ignore errors when stopping scan
    }
  }

  // blue tooth connect
  Future<void> _connectToBluetoothDevice(BluetoothDevice device) async {
    try {
      // Stop scanning before connecting
      await _stopBluetoothScan();

      // Show connecting dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text('Connecting to ${device.platformName}...'),
              ],
            ),
          ),
        );
      }

      // Connect to device
      await device.connect(timeout: const Duration(seconds: 15));

      if (mounted) {
        Navigator.of(context).pop(); // Close connecting dialog

        setState(() {
          // Add device to connected list if not already there
          if (!_connectedBluetoothDevices.any((d) => d.remoteId == device.remoteId)) {
            _connectedBluetoothDevices.add(device);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connected to ${device.platformName}',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close connecting dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to connect: $e',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnectBluetoothDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      if (mounted) {
        setState(() {
          _connectedBluetoothDevices.removeWhere((d) => d.remoteId == device.remoteId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Disconnected from ${device.platformName.isNotEmpty ? device.platformName : "device"}',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to disconnect: $e',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnectAllBluetoothDevices() async {
    for (final device in List.from(_connectedBluetoothDevices)) {
      await _disconnectBluetoothDevice(device);
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
        actions: [
          if (!_showBluetoothDevices && _selectedDevices.isNotEmpty && !_isUnbinding)
            TextButton(
              onPressed: _unbindSelectedDevices,
              child: Text(
                _l10n.unbindCount(_selectedDevices.length),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (_showBluetoothDevices && _connectedBluetoothDevices.isNotEmpty)
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.linkSlash,
                size: 18,
                color: Colors.red,
              ),
              tooltip: 'Disconnect All',
              onPressed: _disconnectAllBluetoothDevices,
            ),
          IconButton(
            icon: FaIcon(
              _showBluetoothDevices ? FontAwesomeIcons.list : FontAwesomeIcons.bluetooth,
              size: 18,
              color: AppColors.primaryColor,
            ),
            tooltip: _showBluetoothDevices ? 'Show Device List' : 'Show Bluetooth',
            onPressed: () {
              setState(() {
                _showBluetoothDevices = !_showBluetoothDevices;
                if (!_showBluetoothDevices) {
                  _stopBluetoothScan();
                }
              });
            },
          ),
        ],
      ),
      // floatingActionButton: _showBluetoothDevices
      //     ? FloatingActionButton.extended(
      //         onPressed: _isBluetoothScanning ? _stopBluetoothScan : _startBluetoothScan,
      //         backgroundColor: _isBluetoothScanning ? Colors.red : AppColors.primaryColor,
      //         icon: FaIcon(
      //           _isBluetoothScanning ? FontAwesomeIcons.stop : FontAwesomeIcons.magnifyingGlass,
      //           size: 16,
      //         ),
      //         label: Text(''),
      //       )
      //     : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _isBluetoothScanning ? _stopBluetoothScan : _startBluetoothScan,
        backgroundColor: _isBluetoothScanning ? Colors.red : AppColors.primaryColor,
        tooltip: '蓝牙连接',
        child: _isBluetoothScanning ? const Icon(Icons.stop, color: Colors.white,) : const Icon(Icons.search, color: Colors.white),
        ),
      body: _isUnbinding ? _buildUnbindingProgress() : _buildBody(),
    );
  }

  Widget _buildUnbindingProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _l10n.unbindingDevices,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _l10n.pleaseWaitProcessingDevices(_selectedDevices.length),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Show Bluetooth view if toggled
    if (_showBluetoothDevices) {
      return _buildBluetoothView();
    }

    return Column(
      children: [
        // Connected Bluetooth devices banner
        if (_connectedBluetoothDevices.isNotEmpty)
          Container(
            color: Colors.green[50],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.bluetooth_connected,
                  size: 20,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bluetooth Connected (${_connectedBluetoothDevices.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _connectedBluetoothDevices.map((d) =>
                          d.platformName.isNotEmpty ? d.platformName : 'Unknown'
                        ).join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: _disconnectAllBluetoothDevices,
                  tooltip: 'Disconnect All',
                ),
              ],
            ),
          ),

        if (_selectedDevices.isNotEmpty)
          Container(
            color: AppColors.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _l10n.selectedDevicesCount(_selectedDevices.length),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectAllDevices,
                  child: Text(
                    _l10n.selectAll,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _clearSelection,
                  child: Text(
                    _l10n.clear,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
      ],
    );
  }

  Widget _buildBluetoothView() {
    // Filter out connected devices from scanned devices
    final scannedDevices = _bluetoothDevices.where((scanResult) {
      return !_connectedBluetoothDevices.any((connected) =>
        connected.remoteId == scanResult.device.remoteId
      );
    }).toList();

    return Column(
      children: [
        // Scanning indicator
        if (_isBluetoothScanning)
          Container(
            color: AppColors.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Scanning for Bluetooth devices...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Main content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connected devices section
              if (_connectedBluetoothDevices.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.bluetooth_connected,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Connected Devices (${_connectedBluetoothDevices.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...(_connectedBluetoothDevices.map((device) => _buildConnectedDeviceCard(device)).toList()),
                const SizedBox(height: 24),
              ],

              // Scanned devices section
              if (scannedDevices.isNotEmpty || _isBluetoothScanning) ...[
                Row(
                  children: [
                    Icon(
                      Icons.bluetooth_searching,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Available Devices (${scannedDevices.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (scannedDevices.isEmpty && _isBluetoothScanning)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Searching for devices...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...(scannedDevices.map((scanResult) => _buildScannedDeviceCard(scanResult)).toList()),
              ],

              // Empty state
              if (_connectedBluetoothDevices.isEmpty && scannedDevices.isEmpty && !_isBluetoothScanning)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.bluetooth,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Bluetooth devices found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the scan button to start',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedDeviceCard(BluetoothDevice device) {
    final deviceName = device.platformName.isNotEmpty ? device.platformName : 'Unknown Device';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bluetooth_connected,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.remoteId.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.link_off,
                size: 20,
                color: Colors.red,
              ),
              onPressed: () => _disconnectBluetoothDevice(device),
              tooltip: 'Disconnect',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedDeviceCard(ScanResult scanResult) {
    final device = scanResult.device;
    final deviceName = device.platformName.isNotEmpty ? device.platformName : 'Unknown Device';
    final rssi = scanResult.rssi;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _connectToBluetoothDevice(device),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bluetooth,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.remoteId.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 12,
                          color: _getRssiColor(rssi),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rssi dBm',
                          style: TextStyle(
                            fontSize: 11,
                            color: _getRssiColor(rssi),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.red;
  }

}