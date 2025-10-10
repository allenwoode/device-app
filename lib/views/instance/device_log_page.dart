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
  String? _errorMessage;
  List<DeviceLog> _logData = [];

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
  }

  Future<void> _loadLogData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final logs = await DeviceService.getDeviceLogs(
        deviceId: widget.deviceId,
      );

      setState(() {
        _logData = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
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
    // Calculate alert statistics by level
    Map<String, int> levelCounts = {};
    for (var log in _logData) {
      String levelKey = log.category;
      levelCounts[levelKey] = (levelCounts[levelKey] ?? 0) + 1;
    }

    int dispatchCount = levelCounts['下发'] ?? 0;
    int normalCount = _logData.length - dispatchCount;
    int totalCount = _logData.length;

    return Container(
      margin: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 0),
      child: totalCount > 0
          ? PieChartCard(
              title: _l10n.operationLogs,
              total: totalCount,
              primaryLabel: _l10n.report,
              primaryValue: normalCount,
              primaryColor: Colors.green,
              secondaryLabel: _l10n.dispatch,
              secondaryValue: dispatchCount,
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
      case '属性上报':
        return Colors.green;
      case '平台下发':
        return Colors.red;
      case '事件上报':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case '属性上报':
        return _l10n.report;
      case '平台下发':
        return _l10n.dispatch;
      case '事件上报':
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 8),
                        _buildLogTable(),
                      ],
                    ),
                  ),
                ),
    );
  }
}