import 'dart:convert';

import 'package:device/models/login_models.dart';
import 'package:device/models/device_models.dart';
import 'package:device/services/storage_service.dart';
import 'package:device/services/device_service.dart';
import 'package:flutter/material.dart';
import '../widgets/pie_chart_card.dart';
import '../widgets/bar_chart_card.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? _currentUser;
  DashboardDevices? _dashboardDevices;
  List<DashboardUsage> _dashboardUsage = [];
  DashboardAlerts? _dashboardAlerts;
  DashboardMessage? _dashboardMessage;
  bool _isLoading = true;
  bool _shouldAnimateCards = true;

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      // Fallback when context is not ready
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _shouldAnimateCards = false;
    });

    await _loadDashboardData();

    setState(() {
      _shouldAnimateCards = true;
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

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final dashboardData = await DeviceService.getDashboardDevices();
      final usageData = await DeviceService.getDashboardUsage();
      final alertsData = await DeviceService.getDashboardAlerts();
      final messageData = await DeviceService.getDashboardMessage();

      setState(() {
        _dashboardDevices = DashboardDevices.fromJson(dashboardData);
        _dashboardUsage = usageData;
        _dashboardAlerts = alertsData;
        _dashboardMessage = messageData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e')),
        );
      }
    }
  }

  List<ChartBarData> _convertUsageToChartData(List<DashboardUsage> usageList) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];

    return usageList.asMap().entries.map((entry) {
      int index = entry.key;
      DashboardUsage usage = entry.value;

      return ChartBarData(
        label: usage.label,
        value: usage.value,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _currentUser?.orgList.isNotEmpty == true
                ? _currentUser!.orgList.first.name
                : _l10n.organizationUnitEmpty,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
              BarChartCard(
                title: _l10n.todayUsageTop5,
                shouldAnimate: _shouldAnimateCards,
                data: _convertUsageToChartData(_dashboardUsage),
                onTap: () {
                  AppRoutes.goToDashboardUsage(context);
                },
              ),
              const SizedBox(height: 16),
              PieChartCard(
                title: _l10n.devices,
                total: _dashboardDevices?.total,
                primaryLabel: _l10n.online,
                primaryValue: _dashboardDevices?.onlineCount ?? 0,
                primaryColor: Colors.green,
                secondaryLabel: _l10n.offline,
                secondaryValue: _dashboardDevices?.offlineCount ?? 0,
                secondaryColor: Colors.grey,
                shouldAnimate: _shouldAnimateCards,
                onTap: () {
                  AppRoutes.goToMain(context);
                },
              ),
              const SizedBox(height: 16),
              PieChartCard(
                title: _l10n.todayAlerts,
                total: _dashboardAlerts?.total,
                primaryLabel: _l10n.notice,
                primaryValue: _dashboardAlerts?.alarmCount ?? 0,
                primaryColor: Colors.green,
                secondaryLabel: _l10n.severe,
                secondaryValue: _dashboardAlerts?.severeCount ?? 0,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
                onTap: () {
                  AppRoutes.goToDashboardAlert(context);
                },
              ),
              const SizedBox(height: 16),
              PieChartCard(
                title: _l10n.operationLogs,
                total: _dashboardMessage?.total,
                primaryLabel: _l10n.report,
                primaryValue: _dashboardMessage?.reportCount ?? 0,
                primaryColor: Colors.green,
                secondaryLabel: _l10n.dispatch,
                secondaryValue: _dashboardMessage?.functionCount ?? 0,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
                onTap: () {
                  AppRoutes.goToDashboardDeviceLog(context);
                },
              ),
                  ],
                ),
              ),
      ),
    );
  }
}

