import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:device/services/device_service.dart';
import 'package:device/models/device_models.dart';

enum LockState {
  locked,
  unlocked,
  charging,
  charged,
  empty
}

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
  final DeviceData device;
  
  const DeviceDetailPage({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  List<LockSlot> lockSlots = [];
  bool _isLoading = true;
  String? _errorMessage;
  ExtraData? _extraData;
  String _deviceName = '';
  String _deviceId = '';
  int _state = 0;
  int? _num;
  
  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }
  
  Future<void> _loadDeviceData() async {
    try {
      final deviceStateData = await DeviceService.getDeviceState(widget.device);
      //final deviceDetailData = await DeviceService.getDeviceDetail(widget.deviceId);

      _deviceId = widget.device.id;
      _deviceName = widget.device.name;
      _state = widget.device.state;

      // device.extra: "extraData": "{\"charge_num\":11,\"gate_num\":11,\"organization\":\"浙江杰马电子科技\",\"power\":\"45W\"}"
      _extraData = ExtraData.decode(widget.device.extraData);
      _num = _extraData?.gateNum;

      _parseDeviceStateData(deviceStateData);
      
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载设备数据失败: ${e.toString().contains('Network error') ? '网络连接失败' : '服务器错误'}';
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
      final lockChar = index < lockStateString.length ? lockStateString[index] : '0';
      final isUnlocked = lockChar == '1';
      
      // Parse charging state (0 = empty, 2 = charging, 1 = charged)
      final chargeChar = index < chargeStateString.length ? chargeStateString[index] : '0';
      LockState chargingState;

      // Parse used state (1 = used, 0 = default)
      final usedChar = index < usedStateString.length ? usedStateString[index] : '0';
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
          '$_deviceId (${_state == 1 ? '在线' : '离线'})',
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
      margin: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
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
          _buildMenuIcon(Icons.pie_chart_outline, '使用率'),
          _buildMenuIcon(Icons.notifications_none, '告警'),
          _buildMenuIcon(Icons.list_alt, '操作日志'),
          _buildMenuIcon(Icons.settings_outlined, '远程设置'),
        ],
      ),
    );
  }
  
  Widget _buildMenuIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
          childAspectRatio: (_num ?? 16) < 12 ? 1 : 0.6,
        ),
        itemCount: _num ?? lockSlots.length,
        itemBuilder: (context, index) {
          return _state == 1 ? _buildOnlineLockSlot(lockSlots[index]) : _buildOfflineLockSlot(lockSlots[index]);
        },
      ),
    );
  }
  
  Widget _buildOnlineLockSlot(LockSlot slot) {
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
                slot.lockState == LockState.unlocked ? Icons.lock_open : Icons.lock,
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
          )
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
              Icon(
                Icons.lock,
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
          )
        ),
        const SizedBox(height: 8),
        // Charging status indicator
        Text(
          '--', 
          style: TextStyle(
            color: Colors.grey, 
            fontSize: 14,
            ),
        ),
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
            ]
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
            ]
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
            ]
          ),
        );
      default:
        return Text('--', style: TextStyle(color: Colors.grey, fontSize: 14),);
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
              Icon(Icons.lock_open, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              const Text('设备开锁', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 24),
              Icon(Icons.lock, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              const Text('设备关锁', style: TextStyle(fontSize: 12)),
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
                  ]
                ),
              ),
              const SizedBox(width: 8),
              const Text('未通电', style: TextStyle(fontSize: 12)),
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
                  ]
                ),
              ),
              const SizedBox(width: 8),
              const Text('充电中', style: TextStyle(fontSize: 12)),
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
                  ]
                ),
              ),
              const SizedBox(width: 8),
              const Text('已充满', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}