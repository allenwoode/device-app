import 'package:device/widgets/pie_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/device_models.dart';
import '../../services/device_service.dart';

class DeviceLogPage extends StatefulWidget {
  final String deviceId;
  final String productId;

  const DeviceLogPage({
    super.key,
    required this.deviceId,
    required this.productId,
  });

  @override
  State<DeviceLogPage> createState() => _DeviceLogPageState();
}

class _DeviceLogPageState extends State<DeviceLogPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<DeviceOperateLog> _logData = [];
  List<Dashboard> _logCountData = [];

  // Pagination state
  int _currentPage = 0;
  final int _pageSize = 12;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

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
    _loadLogData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more data when scrolling near bottom (within 100 pixels)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadLogData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 0;
        _hasMoreData = true;
      });

      final logs = await DeviceService.getDeviceLogs(
        deviceId: widget.deviceId,
        pageIndex: _currentPage,
        pageSize: _pageSize,
      );

      final logCounts = await DeviceService.getDeviceLogCount(
        deviceId: widget.deviceId,
      );

      setState(() {
        _logData = logs;
        _logCountData = logCounts;
        _isLoading = false;
        _hasMoreData = logs.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final logs = await DeviceService.getDeviceLogs(
        deviceId: widget.deviceId,
        pageIndex: nextPage,
        pageSize: _pageSize,
      );

      setState(() {
        _logData.addAll(logs);
        _currentPage = nextPage;
        _hasMoreData = logs.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Network error')) {
      return _l10n.networkConnectionFailed;
    } else {
      return _l10n.serverError;
    }
  }

  Widget _buildTopBar() {

    return Container(
      margin: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 0),
      child: _logCountData.isNotEmpty
          ? PieChartCard(
              title: _l10n.operationLogs,
              total: _logCountData.first.total,
              primaryLabel: _l10n.report,
              primaryValue: _logCountData.first.data[0],
              primaryColor: Colors.green,
              secondaryLabel: _l10n.dispatch,
              secondaryValue: _logCountData.first.data[1],
              secondaryColor: Colors.red[400]!,
              shouldAnimate: true,
            )
          : Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.operationLogs,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _l10n.noLogData,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLogTable() {
    if (_logData.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
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
        child: Center(
          child: Column(
            children: [
              FaIcon(
                FontAwesomeIcons.fileLines,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _l10n.noLogInfo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8),
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
          // Table header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    _l10n.operationLogs,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _l10n.operationTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _logData.length,
            itemBuilder: (context, index) {
              final log = _logData[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(log.category),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getCategoryName(log.category),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log.text,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        log.createTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'report':
        return Colors.green;
      case 'function':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'report':
        return _l10n.report;
      case 'function':
        return _l10n.dispatch;
      case 'event':
        return _l10n.event;
      default:
        return '';
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
                          _loadLogData();
                        },
                        child: Text(_l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLogData,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 8),
                        _buildLogTable(),
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (!_hasMoreData && _logData.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _l10n.noMoreData,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}