import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/device_models.dart';
import '../../services/device_service.dart';
import '../../widgets/bar_chart_card.dart';

class DeviceUsagePage extends StatefulWidget {
  final String deviceId;
  final String productId;

  const DeviceUsagePage({
    super.key,
    required this.deviceId,
    required this.productId,
  });

  @override
  State<DeviceUsagePage> createState() => _DeviceUsagePageState();
}

class _DeviceUsagePageState extends State<DeviceUsagePage> {
  bool _isLoading = true;
  String? _errorMessage;

  List<DeviceUsage> _usageData = [];

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
  }

  Future<void> _loadDeviceData() async {
    try {
      final response = await DeviceService.getDeviceUsage(
        deviceId: widget.deviceId,
      );

      setState(() {
        _usageData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  Widget _buildTopBar() {
    Map<int, int> portUsageCount = {};
    for (var usage in _usageData) {
      portUsageCount[usage.port] = (portUsageCount[usage.port] ?? 0) + 1;
    }

    List<ChartBarData> chartData =
        portUsageCount.entries
            .map(
              (entry) => ChartBarData(
                label: 'C${entry.key}',
                value: entry.value,
                color: _getPortColor(entry.key - 1),
              ),
            )
            .toList()
          ..sort(
            (a, b) => int.parse(
              a.label.substring(1),
            ).compareTo(int.parse(b.label.substring(1))),
          );

    return Container(
      margin: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 0),
      child: chartData.isNotEmpty
          ? BarChartCard(title: _l10n.todayUsage, data: chartData, shouldAnimate: true)
          : Container(
              padding: const EdgeInsets.all(8),
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
                    _l10n.todayUsage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _l10n.noUsageRecords,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }

  Color _getPortColor(int port) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[port % colors.length];
  }

  Color _getDepoColor(String depo) {
    switch (depo) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildUsageTable() {
    if (_usageData.isEmpty) {
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
              FaIcon(FontAwesomeIcons.inbox, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _l10n.noUsageDataAvailable,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                    _l10n.usageInfo,
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
                    _l10n.usageTime,
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
            itemCount: _usageData.length,
            itemBuilder: (context, index) {
              final usage = _usageData[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDepoColor(usage.depo),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        usage.depo == '1' ? _l10n.deposit : _l10n.withdraw,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _l10n.inUse('C${usage.port}'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        usage.formattedCreateTime,
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
                    _buildTopBar(),
                    const SizedBox(height: 8),
                    _buildUsageTable(),
                  ],
                ),
              ),
            ),
    );
  }
}
