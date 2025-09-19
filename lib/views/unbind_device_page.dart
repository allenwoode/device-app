import 'package:flutter/material.dart';
import 'package:device/models/device_models.dart';
import 'package:device/services/device_service.dart';
import 'package:device/config/app_colors.dart';
import 'package:device/widgets/confirm_dialog.dart';
import '../l10n/app_localizations.dart';

class UnbindDevicePage extends StatefulWidget {
  const UnbindDevicePage({super.key});

  @override
  State<UnbindDevicePage> createState() => _UnbindDevicePageState();
}

class _UnbindDevicePageState extends State<UnbindDevicePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _l10n.unbindDevices,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedDevices.isNotEmpty && !_isUnbinding)
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
        ],
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
        Container(
          color: Colors.red.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 16,
                color: Colors.red[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _l10n.unbindWarning,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
}