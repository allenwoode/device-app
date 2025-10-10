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
  List<DeviceData> _devices = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  int? _totalDevices;
  String? _errorMessage;
  final Set<String> _selectedDevices = {};
  bool _isUnbinding = false;

  // Bluetooth related state
  List<ScanResult> _bluetoothDevices = [];
  bool _isBluetoothScanning = false;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  BluetoothDevice? _connectedBluetoothDevice;
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
    _loadDevices();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    _stopBluetoothScan();
    super.dispose();
  }

  void _scrollListener() {
    // 当滚动到距离底部100像素时开始预加载
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreDevices();
      }
    }
  }

  Future<void> _loadDevices({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        setState(() {
          _currentPage = 0;
          _hasMoreData = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final data = await DeviceService.getDevices(index: _currentPage, size: _pageSize);

      if (data['devices'] != null) {
        final List<DeviceData> devices = (data['devices'] as List)
            .map((device) => DeviceData.fromJson(device))
            .toList();

        if (mounted) {
          setState(() {
            if (isRefresh) {
              _devices = devices;
              _currentPage = 0;
            } else {
              _devices = devices;
            }

            // 更新总数信息
            if (data['total'] != null) {
              _totalDevices = data['total'];
            }

            _isLoading = false;
            _errorMessage = null;

            // 使用总数判断是否还有更多数据
            if (_totalDevices != null) {
              _hasMoreData = _devices.length < _totalDevices!;
            } else {
              _hasMoreData = devices.length == _pageSize;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _devices = [];
            _isLoading = false;
            _errorMessage = null;
            _hasMoreData = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _l10n.loadDeviceListFailed;
        });
      }
    }
  }

  Future<void> _loadMoreDevices() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final data = await DeviceService.getDevices(index: nextPage, size: _pageSize);

      if (data['devices'] != null) {
        final List<DeviceData> newDevices = (data['devices'] as List)
            .map((device) => DeviceData.fromJson(device))
            .toList();

        if (mounted) {
          setState(() {
            _devices.addAll(newDevices);
            _currentPage = nextPage;
            _isLoadingMore = false;

            // 更新总数信息
            if (data['total'] != null) {
              _totalDevices = data['total'];
            }

            // 使用总数判断是否还有更多数据
            if (_totalDevices != null) {
              _hasMoreData = _devices.length < _totalDevices!;
            } else {
              // 如果没有总数信息，回退到原来的逻辑
              _hasMoreData = newDevices.length == _pageSize;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
            _hasMoreData = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadDevices(isRefresh: true);
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
      for (final device in _devices) {
        _selectedDevices.add(device.id);
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

    _showUnbindConfirmDialog();
  }

  void _showUnbindConfirmDialog() {
    ConfirmDialog.show(
      context: context,
      title: _l10n.confirmUnbindDevices,
      message: _l10n.confirmUnbindMessage(_selectedDevices.length),
      confirmText: _l10n.unbind,
      cancelText: _l10n.cancel,
      confirmButtonColor: Colors.red,
      onConfirm: () async {
        Navigator.of(context).pop();
        await _performUnbind();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _performUnbind() async {
    setState(() {
      _isUnbinding = true;
    });

    try {
      int successCount = 0;
      int failureCount = 0;

      // Simulate unbinding each device
      for (final deviceId in _selectedDevices) {
        try {
          final success = await DeviceService.unbindDevice(deviceId: deviceId);
          if (success) {
            successCount++;
          } else {
            failureCount++;
          }
        } catch (e) {
          failureCount++;
        }
      }

      if (mounted) {
        setState(() {
          _isUnbinding = false;
        });

        // Show result message
        String message;
        Color backgroundColor;

        if (failureCount == 0) {
          message = _l10n.successfullyUnbound(successCount);
          backgroundColor = Colors.green;
        } else if (successCount == 0) {
          message = _l10n.unbindFailedRetry;
          backgroundColor = Colors.red;
        } else {
          message = _l10n.unbindMixed(successCount, failureCount);
          backgroundColor = Colors.orange;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: backgroundColor,
          ),
        );

        // Clear selection and reload devices
        setState(() {
          _selectedDevices.clear();
        });

        if (successCount > 0) {
          _loadDevices(isRefresh: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUnbinding = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _l10n.unbindOperationError,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        //print('===>results: $results');
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
          _connectedBluetoothDevice = device;
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

  Future<void> _disconnectBluetoothDevice() async {
    if (_connectedBluetoothDevice != null) {
      try {
        await _connectedBluetoothDevice!.disconnect();
        if (mounted) {
          setState(() {
            _connectedBluetoothDevice = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Disconnected from Bluetooth device',
                style: TextStyle(fontSize: 12),
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
          if (_showBluetoothDevices && _connectedBluetoothDevice != null)
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.linkSlash,
                size: 18,
                color: Colors.red,
              ),
              tooltip: 'Disconnect',
              onPressed: _disconnectBluetoothDevice,
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
      floatingActionButton: _showBluetoothDevices
          ? FloatingActionButton.extended(
              onPressed: _isBluetoothScanning ? _stopBluetoothScan : _startBluetoothScan,
              backgroundColor: _isBluetoothScanning ? Colors.red : AppColors.primaryColor,
              icon: FaIcon(
                _isBluetoothScanning ? FontAwesomeIcons.stop : FontAwesomeIcons.magnifyingGlass,
                size: 16,
              ),
              label: Text(_isBluetoothScanning ? 'Stop Scan' : 'Scan Devices'),
            )
          : null,
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadDevices(),
              child: Text(_l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _l10n.noDevicesToUnbind,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final device = _devices[index];
                        final isSelected = _selectedDevices.contains(device.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.red : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _toggleDeviceSelection(device.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    // decoration: BoxDecoration(
                                    //   color: Colors.red[50],
                                    //   borderRadius: BorderRadius.circular(8),
                                    // ),
                                    child: SizedBox(
                                      //width: 48,
                                      //height: 48,
                                      child: Image.asset(
                                        'lib/assets/images/ELLTE-MAX-${device.spec}.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          device.productName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.red : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color: isSelected ? Colors.red : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _devices.length,
                    ),
                  ),
                ),
                if (_isLoadingMore)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _l10n.loadingMoreDevices,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!_hasMoreData && _devices.isNotEmpty && !_isLoading)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _l10n.allDevicesLoadedCount(_totalDevices ?? _devices.length),
                            style: TextStyle(
                              color: Colors.grey[600],
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
        ),
      ],
    );
  }

  Widget _buildBluetoothView() {
    return Column(
      children: [
        // Connected device banner
        if (_connectedBluetoothDevice != null)
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
                      const Text(
                        'Connected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _connectedBluetoothDevice!.platformName.isNotEmpty
                            ? _connectedBluetoothDevice!.platformName
                            : 'Unknown Device',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

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

        // Bluetooth devices list
        Expanded(
          child: _bluetoothDevices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.bluetooth,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isBluetoothScanning
                            ? 'Searching for devices...'
                            : 'No Bluetooth devices found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      if (!_isBluetoothScanning)
                        const SizedBox(height: 8),
                      if (!_isBluetoothScanning)
                        Text(
                          'Tap the scan button to start',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bluetoothDevices.length,
                  itemBuilder: (context, index) {
                    final scanResult = _bluetoothDevices[index];
                    final device = scanResult.device;
                    final isConnected = _connectedBluetoothDevice?.remoteId == device.remoteId;
                    final deviceName = device.platformName.isNotEmpty
                        ? device.platformName
                        : 'Unknown Device';
                    final rssi = scanResult.rssi;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isConnected ? Colors.green : Colors.grey[300]!,
                          width: isConnected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: isConnected ? null : () => _connectToBluetoothDevice(device),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isConnected
                                      ? Colors.green[50]
                                      : AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isConnected
                                      ? Icons.bluetooth_connected
                                      : Icons.bluetooth,
                                  color: isConnected ? Colors.green : AppColors.primaryColor,
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
                              if (isConnected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Connected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.red;
  }

}