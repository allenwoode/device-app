import 'package:device/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:device/services/device_service.dart';
import 'package:device/api/api_config.dart';
import 'package:device/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';

enum LockState { locked, unlocked, charging, charged, empty }

class LockSlot {
  final String id;
  final LockState lockState;
  final LockState chargingState;
  final bool isUsed;

  LockSlot({
    required this.id,
    required this.lockState,
    required this.chargingState,
    required this.isUsed,
  });
}

class DeviceDetailPage extends StatefulWidget {
  final String deviceId;
  final String productId;

  const DeviceDetailPage({
    super.key,
    required this.deviceId,
    required this.productId,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  List<LockSlot> lockSlots = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _deviceName = '';
  int _state = 0;
  int? _num;

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      // Fallback when context is not ready
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Network error')) {
      return 'Network connection failed';
    } else {
      return 'Server error';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    try {
      final deviceDetailData = await DeviceService.getDeviceDetail(
        widget.deviceId,
      );
      _deviceName = deviceDetailData.name;
      _state = deviceDetailData.state;
      _num = deviceDetailData.extraData.gateNum;

      final deviceStateData = await DeviceService.getDeviceState(
        widget.deviceId,
        widget.productId,
      );
      _parseDeviceStateData(deviceStateData);

      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  void _parseDeviceStateData(Map<String, dynamic> stateData) {
    // Initialize with default empty states
    String lockStateString = '0000000000000000';
    String chargeStateString = '0000000000000000';
    String usedStateString = '0000000000000000';

    // Parse state data
    if (stateData['result'] != null && stateData['result'] is List) {
      final List<dynamic> results = stateData['result'];

      for (var result in results) {
        if (result['data'] != null && result['data']['value'] != null) {
          final property = result['data']['value']['property'];
          final state = result['data']['value']['value']['state'];

          if (property == 'LOCK_STATE') {
            lockStateString = state;
          } else if (property == 'CHARGE_STATE') {
            chargeStateString = state;
          } else if (property == 'USED_STATE') {
            usedStateString = state;
          }
        }
      }
    }

    // Generate lock slots from state data
    lockSlots = List.generate(16, (index) {
      final slotId = 'C${index + 1}';

      // Parse lock state (0 = locked, 1 = unlocked)
      final lockChar = index < lockStateString.length
          ? lockStateString[index]
          : '0';
      final isUnlocked = lockChar == '1';

      // Parse charging state (0 = empty, 2 = charging, 1 = charged)
      final chargeChar = index < chargeStateString.length
          ? chargeStateString[index]
          : '0';
      LockState chargingState;

      // Parse used state (1 = used, 0 = default)
      final usedChar = index < usedStateString.length
          ? usedStateString[index]
          : '0';
      final isUsed = usedChar == '1';

      switch (chargeChar) {
        case '1':
          chargingState = LockState.charged;
          break;
        case '2':
          chargingState = LockState.charging;
          break;
        default:
          chargingState = LockState.empty;
      }

      return LockSlot(
        id: slotId,
        lockState: isUnlocked ? LockState.unlocked : LockState.locked,
        chargingState: chargingState,
        isUsed: isUsed,
      );
    });
  }

  void _showConfirmDialog() {
    ConfirmDialog.show(
      context: context,
      title: '设备解绑',
      message: '确定对当前设备解绑吗？',
      confirmText: '解绑',
      confirmButtonColor: AppColors.primaryColor,
      onConfirm: () async {
        await _performUnbindDevice();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _performUnbindDevice() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text('正在处理...'),
            ],
          ),
          duration: const Duration(seconds: 10),
        ),
      );

      final resp = await DeviceService.unbindDevice(deviceId: widget.deviceId);

      // Hide loading indicator if still showing
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (resp) {
        AppRoutes.goToMain(context);
      }
    } catch (err) {
      // Hide loading indicator if still showing
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败'), backgroundColor: Colors.orange),
      );

      if (ApiConfig.enableLogging) {
        print('Device unbind failed: $err');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
          '${widget.deviceId} (${_state == 1 ? _l10n.online : _l10n.offline})',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showConfirmDialog,
            icon: const FaIcon(
              FontAwesomeIcons.circleMinus,
              color: Colors.black,
              size: 18,
            ),
            tooltip: '解绑设备',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _loadDeviceData();
                    },
                    child: Text(_l10n.retry),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDeviceData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildTopMenu(),
                    const SizedBox(height: 8),
                    _buildLockGrid(),
                    const SizedBox(height: 8),
                    _buildLegend(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuIcon(
            FontAwesomeIcons.chartArea,
            _l10n.usageRate,
            onPressed: () {
              AppRoutes.goToDeviceUsage(
                context,
                widget.deviceId,
                widget.productId,
                _num,
              );
            },
          ),
          _buildMenuIcon(
            FontAwesomeIcons.solidBell,
            _l10n.alerts,
            onPressed: () {
              AppRoutes.goToDeviceAlert(
                context,
                widget.deviceId,
                widget.productId,
              );
            },
          ),
          _buildMenuIcon(
            FontAwesomeIcons.clipboardList,
            _l10n.operationLog,
            onPressed: () {
              AppRoutes.goToDeviceLog(
                context,
                widget.deviceId,
                widget.productId,
              );
            },
          ),
          _buildMenuIcon(
            FontAwesomeIcons.gear,
            _l10n.remoteSettings,
            onPressed: () {
              if (_state == 1) {
                AppRoutes.goToDeviceFunction(
                  context,
                  widget.deviceId,
                  widget.productId,
                  _num,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _l10n.deviceOfflineCannotRemoteSet,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        //borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withOpacity(0.2),
        //highlightColor: Colors.white.withOpacity(0.2),
        splashFactory: InkRipple.splashFactory,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              FaIcon(icon, size: 24, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.1),
      //       spreadRadius: 0,
      //       blurRadius: 4,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (_num ?? 16) < 12 ? 3 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: (_num ?? 16) < 12 ? 0.8 : 0.6,
        ),
        itemCount: _num ?? lockSlots.length,
        itemBuilder: (context, index) {
          return _state == 1
              ? _buildOnlineLockSlot(lockSlots[index])
              : _buildOfflineLockSlot(lockSlots[index]);
        },
      ),
    );
  }

  Widget _buildOnlineLockSlot(LockSlot slot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular background with lock icon and ripple effect
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle lock slot tap - could open a dialog or perform action
              _showLockSlotDialog(slot);
            },
            borderRadius: BorderRadius.circular(32),
            splashColor: Colors.blue.withOpacity(0.3),
            highlightColor: Colors.blue.withOpacity(0.15),
            splashFactory: InkRipple.splashFactory,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slot.isUsed ? Colors.white : Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    slot.lockState == LockState.unlocked
                        ? FontAwesomeIcons.lockOpen
                        : FontAwesomeIcons.lock,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 4),
                  // Slot ID
                  Text(
                    slot.id,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Charging status indicator
        _buildChargingStatusIndicator(slot.chargingState),
      ],
    );
  }

  Widget _buildOfflineLockSlot(LockSlot slot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular background with lock icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.lock, size: 20, color: Colors.grey[600]),
              const SizedBox(height: 4),
              // Slot ID
              Text(
                slot.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Charging status indicator
        Text('--', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildChargingStatusIndicator(LockState state) {
    switch (state) {
      case LockState.charging:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00a0e9),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      case LockState.charged:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF55bf4f),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      case LockState.empty:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      default:
        return Text('--', style: TextStyle(color: Colors.grey, fontSize: 14));
    }
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.1),
      //       spreadRadius: 0,
      //       blurRadius: 4,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          // Lock status legend
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lockOpen,
                color: Colors.grey[600],
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(_l10n.deviceUnlock, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 24),
              FaIcon(FontAwesomeIcons.lock, color: Colors.grey[600], size: 14),
              const SizedBox(width: 8),
              Text(_l10n.deviceLock, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          // Charging status legend
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(_l10n.notPowered, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(0xFF00a0e9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(_l10n.charging, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(0xFF55bf4f),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(_l10n.fullyCharged, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  void _showLockSlotDialog(LockSlot slot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('${slot.id} State'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lock: ${slot.lockState == LockState.unlocked ? 'Unlock' : 'Lock'}',
              ),
              const SizedBox(height: 8),
              Text('Charge: ${_getChargingStatusText(slot.chargingState)}'),
              const SizedBox(height: 8),
              Text('Used: ${slot.isUsed ? 'In Use' : 'Idle'}'),
            ],
          ),
          actions: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                splashColor: Colors.grey.withOpacity(0.3),
                highlightColor: Colors.grey.withOpacity(0.15),
                splashFactory: InkRipple.splashFactory,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            // if (slot.lockState == LockState.locked && _state == 1)
            //   Material(
            //     color: Colors.transparent,
            //     child: InkWell(
            //       onTap: () {
            //         Navigator.of(context).pop();
            //         _performLockAction(slot);
            //       },
            //       borderRadius: BorderRadius.circular(8),
            //       splashColor: Colors.blue.withOpacity(0.3),
            //       highlightColor: Colors.blue.withOpacity(0.15),
            //       splashFactory: InkRipple.splashFactory,
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //         child: const Text(
            //           '开锁',
            //           style: TextStyle(color: Colors.blue),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        );
      },
    );
  }

  String _getChargingStatusText(LockState state) {
    switch (state) {
      case LockState.charging:
        return 'Charging';
      case LockState.charged:
        return 'Fully Charged';
      case LockState.empty:
        return 'Not Powered';
      default:
        return 'Unknown';
    }
  }

  // void _performLockAction(LockSlot slot) async {
  //   try {
  //     final portNumber = int.parse(slot.id.substring(1));

  //     final success = await DeviceService.invokeDeviceLockOpen(
  //       deviceId: widget.deviceId,
  //       port: portNumber,
  //     );

  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('${slot.id} 开锁成功'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       _loadDeviceData();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('${slot.id} 开锁失败'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${slot.id} 开锁操作异常: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
}
