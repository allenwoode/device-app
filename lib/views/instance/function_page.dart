import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:device/services/device_service.dart';
import 'package:device/api/api_config.dart';
import '../../l10n/app_localizations.dart';

enum LockState { locked, unlocked }

class LockSlot {
  final String id;
  final LockState lockState;

  LockSlot({required this.id, required this.lockState});
}

class FunctionPage extends StatefulWidget {
  final String deviceId;
  final String productId;
  final int? num;

  const FunctionPage({
    super.key,
    required this.deviceId,
    required this.productId,
    required this.num,
  });

  @override
  State<FunctionPage> createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  List<LockSlot> lockSlots = [];
  bool _isLoading = true;
  String? _errorMessage;
  //String _deviceName = '';

  AppLocalizations get _l10n {
    try {
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        return localizations;
      }
    } catch (e) {
      // Context not ready or MaterialLocalizations not available
    }

    // Fallback when context is not ready or MaterialLocalizations not found
    return lookupAppLocalizations(const Locale('zh'));
  }

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    try {
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
        _errorMessage = _l10n.loadDeviceDataFailed;
      });
    }
  }

  void _parseDeviceStateData(Map<String, dynamic> stateData) {
    // Initialize with default empty states
    String lockStateString = '0000000000000000';

    // Parse state data
    if (stateData['result'] != null && stateData['result'] is List) {
      final List<dynamic> results = stateData['result'];

      for (var result in results) {
        if (result['data'] != null && result['data']['value'] != null) {
          final property = result['data']['value']['property'];
          final state = result['data']['value']['value']['state'];

          if (property == 'LOCK_STATE') {
            lockStateString = state;
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

      return LockSlot(
        id: slotId,
        lockState: isUnlocked ? LockState.unlocked : LockState.locked,
      );
    });
  }

  Widget _buildLockGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 16),
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
          crossAxisCount: (widget.num ?? 16) < 12 ? 3 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: (widget.num ?? 16) < 12 ? 0.7 : 0.5,
        ),
        itemCount: widget.num ?? lockSlots.length,
        itemBuilder: (context, index) {
          return _buildLockSlot(lockSlots[index], index);
        },
      ),
    );
  }

  Widget _buildLockSlot(LockSlot slot, int index) {
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
            color: slot.lockState == LockState.unlocked ? Colors.white : Colors.grey[300],
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
              Icon(
                slot.lockState == LockState.unlocked
                    ? Icons.lock_open
                    : Icons.lock,
                size: 24,
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
        const SizedBox(height: 8),
        // Charging status indicator
        _buildLockSelector(slot.lockState, slot.id),
      ],
    );
  }

  Widget _buildLockSelector(LockState state, String slotId) {
    return CupertinoSwitch(
      value: state == LockState.unlocked,
      onChanged: (bool value) {
        // Only show dialog when unlocking (value is true)
        if (value) {
          _showLockControlDialog(value, slotId);
        } else {
          // Show tip message when trying to lock (close)
          _showMessage(_l10n.deviceCannotRemoteClose);
        }
      },
      activeTrackColor: CupertinoColors.systemGreen,
    );
  }

  void _showLockControlDialog(bool isUnlocking, String slotId) {
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;
    String? passwordError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    _l10n.remoteOpenCabinetDoor(slotId),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Password input field
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: _l10n.pleaseEnterAdminPassword,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      errorText: passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _l10n.cancel,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (passwordController.text.isEmpty) {
                          setState(() {
                            passwordError = _l10n.pleaseEnterAdminPassword;
                          });
                          return;
                        }
                        _handleLockControl(slotId, isUnlocking, passwordController.text);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _l10n.confirm,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleLockControl(String slotId, bool isUnlocking, String password) async {
    // TODO: Add password validation with backend
    // For now, proceed if password is provided

    _showMessage(_l10n.cabinetDoorOpening(slotId));

    try {
      // Calculate the port number from slot ID (C1 -> port 1, C2 -> port 2, etc.)
      final slotIndex = int.parse(slotId.substring(1)) - 1;
      final port = slotIndex + 1; // Port numbers start from 1

      // Make API call to open the lock
      final success = await DeviceService.invokeDeviceLockOpen(
        deviceId: widget.deviceId,
        port: port,
        type: "1",
      );

      if (success) {
        _showMessage(_l10n.cabinetDoorOpenedSuccessfully(slotId));

        // Update the local state to reflect the change
        setState(() {
          if (slotIndex >= 0 && slotIndex < lockSlots.length) {
            lockSlots[slotIndex] = LockSlot(
              id: lockSlots[slotIndex].id,
              lockState: LockState.unlocked,
            );
          }
        });
      } else {
        _showMessage(_l10n.cabinetDoorOpenFailed(slotId));
      }
    } catch (e) {
      _showMessage(_l10n.networkError);
      if (ApiConfig.enableLogging) {
        print('Lock control error: $e');
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.deviceId,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
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
                child: _buildLockGrid(),
              ),
            ),
    );
  }
}
