import 'package:flutter/material.dart';
import '../api/device_api.dart';

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
  final String deviceId;
  
  const DeviceDetailPage({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  List<LockSlot> lockSlots = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _deviceName = '';
  
  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }
  
  Future<void> _loadDeviceData() async {
    try {
      final deviceStateData = await DeviceApi.getDeviceState(widget.deviceId);
      final deviceDetailData = await DeviceApi.getDeviceDetail(widget.deviceId);
      
      _parseDeviceData(deviceStateData, deviceDetailData);
      
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
  
  void _parseDeviceData(Map<String, dynamic> stateData, Map<String, dynamic> detailData) {
    // Extract device name from detail data
    if (detailData['result'] != null && detailData['result']['name'] != null) {
      _deviceName = detailData['result']['id'];
    }
    
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _deviceName.isNotEmpty ? _deviceName : widget.deviceId,
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
                        const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(16),
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: lockSlots.length,
        itemBuilder: (context, index) {
          return _buildLockSlot(lockSlots[index]);
        },
      ),
    );
  }
  
  Widget _buildLockSlot(LockSlot slot) {
    print(slot);
    return Column(
      children: [
        // Lock icon
        Expanded(
          flex: 2,
          child: Icon(
            slot.lockState == LockState.unlocked ? Icons.lock_open : Icons.lock,
            size: 24,
            color: slot.isUsed ? Colors.red : Colors.grey,
          ),
        ),
        // Slot ID
        Text(
          slot.id,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Charging indicator
        Expanded(
          flex: 1,
          child: _buildChargingIndicator(slot.chargingState),
        ),
      ],
    );
  }
  
  Widget _buildChargingIndicator(LockState chargingState) {
    switch (chargingState) {
      case LockState.charging:
        return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.cyan,
            shape: BoxShape.circle,
          ),
        );
      case LockState.charged:
        return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        );
      default:
        return Text(
          "--",
          style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
          )
        );
    }
  }
  
  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Lock status legend
          Row(
            children: [
              const Icon(Icons.lock_open, color: Colors.red, size: 16),
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
              Text(
                "--",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )
              ),
              const SizedBox(width: 8),
              const Text('未充电', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.cyan,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('充电中', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
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