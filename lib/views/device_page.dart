import 'package:device/config/app_colors.dart';
import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:device/models/device_models.dart';
import 'package:device/services/device_service.dart';
import 'package:device/widgets/device_card.dart';
import 'package:device/services/storage_service.dart';
import 'package:device/models/login_models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> with WidgetsBindingObserver {
  User? _currentUser;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<DeviceData> _devices = [];
  List<DeviceData> _filteredDevices = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  int? _totalDevices;
  String? _errorMessage;

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      // Fallback when context is not ready
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadUserInfo();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _searchController.removeListener(_performSearch);
    _scrollController.dispose();
    _searchController.dispose();
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

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _filteredDevices = _devices;
    } else {
      _filteredDevices = _devices.where((device) {
        return device.id.contains(query) ||
               device.name.contains(query);
      }).toList();
    }
  }

  void _performSearch() {
    setState(() {
      _onSearchChanged();
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfoString = await StorageService.getUserInfo();
      if (userInfoString != null) {
        final userJson = jsonDecode(userInfoString);
        setState(() {
          _currentUser = User.fromJson(userJson);
        });
      }
    } catch (e) {
      setState(() {

      });
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

            // 更新过滤后的设备列表
            _onSearchChanged();

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
            _filteredDevices = [];
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
          _errorMessage = _l10n.loadingDevicesFailed;
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

            // 更新过滤后的设备列表
            _onSearchChanged();

            // 更新总数信息
            if (data['total'] != null) {
              _totalDevices = data['total'];
            }

            // 使用总数判断是否还有更多数据
            if (_totalDevices != null) {
              _hasMoreData = _devices.length < _totalDevices!;
              //print('====> 当前已加载: ${_devices.length}, 总数: $_totalDevices, 还有更多: $_hasMoreData');
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

  void _onScanDevice() async {
    // Navigate to Add Device page
    final result = await AppRoutes.goToDeviceBind(context);

    // Refresh device list if a device was successfully bound
    if (result == true) {
      _loadDevices(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _currentUser?.orgName ?? _l10n.organizationUnitEmpty,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _onScanDevice,
            icon: const FaIcon(
              FontAwesomeIcons.circlePlus,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
        ],
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
                onChanged: (value) {
                  setState(() {
                    // This triggers rebuild to update the suffixIcon
                  });
                },
                decoration: InputDecoration(
                  hintText: _l10n.searchDeviceIdName,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              // Trigger rebuild to hide clear button and update results
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Device Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
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
                                      onPressed: _loadDevices,
                                      child: Text(_l10n.retry),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : _filteredDevices.isEmpty
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
                                      _l10n.noDeviceData,
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
                        : CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(16),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.85,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return DeviceCard(device: _filteredDevices[index]);
                                    },
                                    childCount: _filteredDevices.length,
                                  ),
                                ),
                              ),
                              if (_isLoadingMore)
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
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
                              if (!_hasMoreData && _filteredDevices.isNotEmpty && !_isLoading)
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
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
                                          _l10n.allDevicesLoaded(_totalDevices ?? _filteredDevices.length),
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
      ),
    );
  }
}
