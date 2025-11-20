import 'package:device/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:device/services/device_service.dart';
import 'package:device/api/api_config.dart';
import 'package:device/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../services/websocket_service.dart';
import 'dart:async';

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
  //String _deviceName = '';
  int _state = 0;
  int? _num;

  StreamSubscription<Map<String, dynamic>>? _deviceStatusSubscription;
  StreamSubscription<Map<String, dynamic>>? _deviceStateSubscription;

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

    _subscribeDeviceStatusUpdates();
    _subscribeToDeviceStateUpdates();
  }

  @override
  void dispose() {
    _deviceStatusSubscription?.cancel();
    _unsubscribeDeviceStatusUpdates();

    _deviceStateSubscription?.cancel();
    _unsubscribeDeviceStateUpdates();

    super.dispose();
  }

  Future<void> _loadDeviceData() async {
    try {
      final device = await DeviceService.getDeviceDetail(widget.deviceId);
      //_deviceName = device.name;
      _state = device.state;
      _num = device.spec;

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

  void _unsubscribeDeviceStatusUpdates() {
    final deviceId = widget.deviceId;
    final id = 'instance-editor-info-status-$deviceId';
    final topic = '/dashboard/device/status/change/realTime';
    WebSocketService.unsubscribe(id, topic);
  }

  void _subscribeDeviceStatusUpdates() {
    final deviceId = widget.deviceId;
    final id = 'app-instance-info-status-$deviceId';
    final topic = '/dashboard/device/status/change/realTime';
    final parameter = {'deviceId': deviceId};

    _deviceStatusSubscription =
        WebSocketService.subscribe(id, topic, parameter: parameter).listen(
          (message) {
            if (mounted) {
              //print('===>listen device status: $message');
              _handleDeviceStatusUpdate(message);
            }
          },
          onError: (error) {
            if (ApiConfig.enableLogging) {
              print('WebSocket device status error: $error');
            }
          },
        );
  }

  void _unsubscribeDeviceStateUpdates() {
    final deviceId = widget.deviceId;
    final productId = widget.productId;
    final id =
        'app-instance-info-property-$deviceId-$productId-CHARGE_STATE-LOCK_STATE-USED_STATE';
    final topic = '/dashboard/device/$productId/properties/realTime';

    WebSocketService.unsubscribe(id, topic);
  }

  void _subscribeToDeviceStateUpdates() {
    final deviceId = widget.deviceId;
    final productId = widget.productId;
    final id =
        'app-instance-info-property-$deviceId-$productId-CHARGE_STATE-LOCK_STATE-USED_STATE';
    final topic = '/dashboard/device/$productId/properties/realTime';
    final parameter = {
      'deviceId': deviceId,
      'properties': ['CHARGE_STATE', 'LOCK_STATE', 'USED_STATE'],
      'history': 1,
    };

    _deviceStateSubscription =
        WebSocketService.subscribe(id, topic, parameter: parameter).listen(
          (message) {
            if (mounted) {
              _handleDeviceStateUpdate(message);
            }
          },
          onError: (error) {
            if (ApiConfig.enableLogging) {
              print('WebSocket device state error: $error');
            }
          },
        );
  }

  void _handleDeviceStatusUpdate(Map<String, dynamic> message) {
    try {
      // Extract payload from WebSocket message based on assets/device_status_message.json structure
      final payload = message['payload'];
      if (payload != null && payload['value'] != null) {
        final value = payload['value'];
        final type = value['type'] as String?;
        final deviceId = value['deviceId'] as String?;

        if (type != null && deviceId == widget.deviceId) {
          setState(() {
            // Update device state: online = 1, offline = 0
            _state = type == 'online' ? 1 : 0;
          });
        }
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Failed to handle device status update: $e');
      }
    }
  }

  void _handleDeviceStateUpdate(Map<String, dynamic> message) {
    try {
      // Extract payload from WebSocket message based on assets/device_state_message.json structure
      final payload = message['payload'];
      if (payload != null && payload['value'] != null) {
        final value = payload['value'];
        final property = value['property'] as String?;
        final stateValue = value['value'];

        if (property != null && stateValue != null) {
          setState(() {
            _updateDevicePropertyState(property, stateValue);
          });
        }
      }
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Failed to handle device state update: $e');
      }
    }
  }

  void _updateDevicePropertyState(
    String property,
    Map<String, dynamic> stateValue,
  ) {
    final stateString = stateValue['state'] as String?;
    if (stateString == null) return;

    // Update the specific property state
    if (property == 'CHARGE_STATE') {
      _updateChargeState(stateString);
    } else if (property == 'LOCK_STATE') {
      _updateLockState(stateString);
    } else if (property == 'USED_STATE') {
      _updateUsedState(stateString);
    }

    // Regenerate lock slots with updated states
    _regenerateLockSlots();
  }

  void _updateChargeState(String chargeStateString) {
    // Update charge states for all slots
    for (int index = 0; index < lockSlots.length; index++) {
      if (index < chargeStateString.length) {
        final chargeChar = chargeStateString[index];
        LockState chargingState;

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

        lockSlots[index] = LockSlot(
          id: lockSlots[index].id,
          lockState: lockSlots[index].lockState,
          chargingState: chargingState,
          isUsed: lockSlots[index].isUsed,
        );
      }
    }
  }

  void _updateLockState(String lockStateString) {
    // Update lock states for all slots
    for (int index = 0; index < lockSlots.length; index++) {
      if (index < lockStateString.length) {
        final lockChar = lockStateString[index];
        final isUnlocked = lockChar == '1';

        lockSlots[index] = LockSlot(
          id: lockSlots[index].id,
          lockState: isUnlocked ? LockState.unlocked : LockState.locked,
          chargingState: lockSlots[index].chargingState,
          isUsed: lockSlots[index].isUsed,
        );
      }
    }
  }

  void _updateUsedState(String usedStateString) {
    // Update used states for all slots
    for (int index = 0; index < lockSlots.length; index++) {
      if (index < usedStateString.length) {
        final usedChar = usedStateString[index];
        final isUsed = usedChar == '1';

        lockSlots[index] = LockSlot(
          id: lockSlots[index].id,
          lockState: lockSlots[index].lockState,
          chargingState: lockSlots[index].chargingState,
          isUsed: isUsed,
        );
      }
    }
  }

  void _regenerateLockSlots() {
    // Ensure we have the right number of slots based on device spec
    final targetSlotCount = _num ?? 16;
    if (lockSlots.length != targetSlotCount) {
      // Regenerate slots if count doesn't match
      lockSlots = List.generate(targetSlotCount, (index) {
        final slotId = 'C${index + 1}';
        return index < lockSlots.length
            ? lockSlots[index]
            : LockSlot(
                id: slotId,
                lockState: LockState.locked,
                chargingState: LockState.empty,
                isUsed: false,
              );
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

  // void _showConfirmDialog() {
  //   ConfirmDialog.show(
  //     context: context,
  //     title: _l10n.unbindDevices,
  //     message: _l10n.confirmDeviceUnbind,
  //     confirmText: _l10n.unbind,
  //     confirmButtonColor: AppColors.dangerColor,
  //     onConfirm: () async {
  //       await _performUnbindDevice();
  //     },
  //     onCancel: () => Navigator.of(context).pop(),
  //   );
  // }

  // Future<void> _performUnbindDevice() async {
  //   try {
  //     // Show loading indicator
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             const SizedBox(
  //               width: 20,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //               ),
  //             ),
  //             const SizedBox(width: 16),
  //             Text(_l10n.processing),
  //           ],
  //         ),
  //         duration: const Duration(seconds: 30),
  //       ),
  //     );

  //     final resp = await DeviceService.unbindDevice(deviceId: widget.deviceId);

  //     // Hide loading indicator if still showing
  //     ScaffoldMessenger.of(context).hideCurrentSnackBar();

  //     if (resp) {
  //       AppRoutes.goToMain(context);
  //     }
  //   } catch (err) {
  //     // Hide loading indicator if still showing
  //     ScaffoldMessenger.of(context).hideCurrentSnackBar();

  //     // Show error dialog
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(_l10n.failed), backgroundColor: Colors.orange),
  //     );

  //     if (ApiConfig.enableLogging) {
  //       print('Device unbind failed: $err');
  //     }
  //   }
  // }

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.deviceId,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              //margin: const EdgeInsets.only(top: 18, bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _state == 1 ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _state == 1 ? _l10n.online : _l10n.offline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // IconButton(
          //   onPressed: _showConfirmDialog,
          //   icon: const FaIcon(
          //     FontAwesomeIcons.circleMinus,
          //     color: Colors.red,
          //     size: 18,
          //   ),
          // ),
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
            FontAwesomeIcons.chartColumn,
            _l10n.usageRate,
            onPressed: () {
              AppRoutes.goToDeviceUsage(
                context,
                widget.deviceId,
                widget.productId,
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
        highlightColor: Colors.white.withOpacity(0.2),
        splashFactory: InkRipple.splashFactory,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              FaIcon(icon, size: 24, color: Colors.black54),
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
          childAspectRatio: (_num ?? 16) < 12 ? 0.9 : 0.6,
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
              FaIcon(FontAwesomeIcons.lockOpen, color: Colors.grey[600], size: 14),
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
          title: Text(slot.id),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(_l10n.usageStatus),
                const SizedBox(width: 8),
                Text(slot.isUsed ? _l10n.inUse(slot.id) : _l10n.inIdel(slot.id), style: const TextStyle(fontSize: 12)),
              ],),
              const SizedBox(height: 8),
              Row(children: [
                Text(_l10n.lockStatus),
                const SizedBox(width: 8),
                _getLockedInicator(slot.lockState),
                ]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(_l10n.chargingStatus),
                  const SizedBox(width: 8),
                  _getChargedIndicator(slot.chargingState),
                ],
              ),
            ],
          ),
          // actions: [
          //   Material(
          //     color: Colors.transparent,
          //     child: InkWell(
          //       onTap: () => Navigator.of(context).pop(),
          //       borderRadius: BorderRadius.circular(8),
          //       splashColor: Colors.grey.withOpacity(0.3),
          //       highlightColor: Colors.grey.withOpacity(0.15),
          //       splashFactory: InkRipple.splashFactory,
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 8,
          //         ),
          //         child: Text(
          //           'Close',
          //           style: TextStyle(color: Colors.grey[600]),
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        );
      },
    );
  }

  // String _getChargingStatusText(LockState state) {
  //   switch (state) {
  //     case LockState.charging:
  //       return 'Charging';
  //     case LockState.charged:
  //       return 'Fully Charged';
  //     case LockState.empty:
  //       return 'Not Powered';
  //     default:
  //       return 'Unknown';
  //   }
  // }

  Widget _getLockedInicator(LockState state) {
    if (state == LockState.locked) {
      return Row(children: [
        FaIcon(FontAwesomeIcons.lock, color: Colors.grey[600], size: 14),
        const SizedBox(width: 8),
        Text(_l10n.deviceLock, style: const TextStyle(fontSize: 12)),
      ],
      );
    } else {
      return Row(children: [
        FaIcon(FontAwesomeIcons.lockOpen, color: Colors.grey[600], size: 14),
        const SizedBox(width: 8),
        Text(_l10n.deviceUnlock, style: const TextStyle(fontSize: 12)),
      ],
      );
    }
  }

  Widget _getChargedIndicator(LockState state) {
    switch (state) {
      case LockState.empty:
        return Row(children: [
          Container (
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
          ],
        );
      case LockState.charging:
        return Row(children: [
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
        ],
        );
      case LockState.charged:
        return Row(children: [
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
      );
      default:
        return const SizedBox(width: 8,);
    }
  }
}
