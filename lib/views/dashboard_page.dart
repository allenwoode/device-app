import 'dart:convert';

import 'package:device/models/login_models.dart';
import 'package:device/services/storage_service.dart';
import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';
import '../l10n/app_localizations.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? _currentUser;
  bool _isRefreshing = false;
  bool _shouldAnimateCards = true;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
      _shouldAnimateCards = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _shouldAnimateCards = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isRefreshing = false;
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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DashboardCard(
                title: _l10n.devices,
                total: 50,
                primaryLabel: _l10n.online,
                primaryValue: 40,
                primaryColor: Colors.green,
                secondaryLabel: _l10n.offline,
                secondaryValue: 10,
                secondaryColor: Colors.grey,
                shouldAnimate: _shouldAnimateCards,
              ),
              const SizedBox(height: 16),
              DashboardCard(
                title: _l10n.usageDistribution,
                total: null,
                primaryLabel: '>60%',
                primaryValue: 30,
                primaryColor: Colors.green,
                secondaryLabel: '<10%',
                secondaryValue: 10,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
              ),
              const SizedBox(height: 16),
              DashboardCard(
                title: _l10n.todayAlerts,
                total: 50,
                primaryLabel: _l10n.alarm,
                primaryValue: 40,
                primaryColor: Colors.green,
                secondaryLabel: _l10n.severe,
                secondaryValue: 10,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
              ),
              const SizedBox(height: 16),
              DashboardCard(
                title: _l10n.operationLog,
                total: 50,
                primaryLabel: _l10n.deviceReport,
                primaryValue: 40,
                primaryColor: Colors.green,
                secondaryLabel: _l10n.platformDispatch,
                secondaryValue: 10,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

