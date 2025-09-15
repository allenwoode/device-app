import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:device/services/device_service.dart';

enum LockState { locked, unlocked }

class LockSlot {
  final String id;
  final LockState lockState;
  final bool isUsed;

  LockSlot({required this.id, required this.lockState, required this.isUsed});
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
        _errorMessage =
            '加载设备数据失败!';
      });
    }
  }

  void _parseDeviceStateData(Map<String, dynamic> stateData) {
    // Initialize with default empty states
    String lockStateString = '0000000000000000';
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

      // Parse used state (1 = used, 0 = default)
      final usedChar = index < usedStateString.length
          ? usedStateString[index]
          : '0';
      final isUsed = usedChar == '1';

      return LockSlot(
        id: slotId,
        lockState: isUnlocked ? LockState.unlocked : LockState.locked,
        isUsed: isUsed,
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
          childAspectRatio: (widget.num ?? 16) < 12 ? 0.8 : 0.6,
        ),
        itemCount: widget.num ?? lockSlots.length,
        itemBuilder: (context, index) {
          return _buildLockSlot(lockSlots[index]);
        },
      ),
    );
  }

  Widget _buildLockSlot(LockSlot slot) {
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
        _buildLockSelector(slot.lockState),
      ],
    );
  }

  Widget _buildLockSelector(LockState state) {
    return CupertinoSwitch(
      value: state == LockState.unlocked,
      onChanged: (bool value) {
        setState(() {
          
        });
      },
      activeTrackColor: CupertinoColors.systemGreen,
    );
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
                    child: const Text('重试'),
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
