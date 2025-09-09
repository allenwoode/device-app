
import 'dart:ffi';

import 'package:flutter/material.dart';
import '../api/device_api.dart';
import 'device_detail_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<DeviceData> _devices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final data = await DeviceApi.getDevices();
      final List<DeviceData> devices = (data['devices'] as List)
          .map((device) => DeviceData.fromJson(device))
          .toList();
      
      setState(() {
        _devices = devices;
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

  Future<void> _onRefresh() async {
    setState(() {
      _errorMessage = null;
    });
    await _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '浙江杰马电子科技',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索设备ID/名称',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          // Device Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: _errorMessage != null
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
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
                                      onPressed: () {
                                        setState(() {
                                          _isLoading = true;
                                          _errorMessage = null;
                                        });
                                        _loadDevices();
                                      },
                                      child: const Text('重试'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : _devices.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  child: Center(
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
                                          '暂无设备数据',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16),
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: _devices.length,
                                  itemBuilder: (context, index) {
                                    return DeviceCard(device: _devices[index]);
                                  },
                                ),
                              ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '物联网',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: '仪表盘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final DeviceData device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceDetailPage(deviceId: device.id),
          ),
        );
      },
      child: Container(
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
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    device.id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    device.state == 1 ? '在线' : '离线',
                    style: TextStyle(
                      color: device.state == 1 ? Colors.green : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // WiFi Icon
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.wifi,
                  color: device.state == 1 ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Device Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.productName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class DeviceData {
  final String id;
  final int state;
  final String name;
  final String productName;
  final String description;
  final String lastUpdated;

  DeviceData({
    required this.id,
    required this.state,
    required this.name,
    required this.productName,
    required this.description,
    required this.lastUpdated,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      id: json['id'] ?? json['deviceId'] ?? '',
      state: json['state']?['value'] == 'online' ? 1 : 0,
      name: json['name'] ?? json['deviceName'] ?? '',
      productName: json['productName'] ?? json['productName'] ?? '',
      description: json['description'] ?? json['description'] ?? '',
      lastUpdated: json['createTime']?.toString() ?? json['lastUpdated'] ?? '',
    );
  }
}