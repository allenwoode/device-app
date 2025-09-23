import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/device_models.dart';
import '../services/device_service.dart';
import '../widgets/pie_chart_card.dart';
import '../routes/app_routes.dart';

class DashboardAlertPage extends StatefulWidget {
  const DashboardAlertPage({super.key});

  @override
  State<DashboardAlertPage> createState() => _DashboardAlertPageState();
}

class _DashboardAlertPageState extends State<DashboardAlertPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<DashboardUsageDevice> _alertData = [];

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
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
    _loadDashboardAlertData();
  }

  Future<void> _loadDashboardAlertData() async {
    try {
      final response = await DeviceService.getDashboardAlertDevice();

      setState(() {
        _alertData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  Widget _buildAlertChart() {
    if (_alertData.isEmpty) {
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
              FaIcon(FontAwesomeIcons.chartPie, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _l10n.noAlertData,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _alertData.map((alert) => Container(
        margin: const EdgeInsets.all(8),
        child: PieChartCard(
          title: alert.label,
          total: alert.total,
          primaryLabel: _l10n.alarm,
          primaryValue: alert.depo.isNotEmpty ? alert.depo[0] : 0,
          primaryColor: Colors.green,
          secondaryLabel: _l10n.severe,
          secondaryValue: alert.depo.length > 1 ? alert.depo[1] : 0,
          secondaryColor: Colors.red,
          shouldAnimate: true,
          onTap: () {
            AppRoutes.goToDeviceAlert(
              context,
              alert.id,
              'default-product-id',
            );
          },
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          _l10n.todayAlerts,
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
                      _loadDashboardAlertData();
                    },
                    child: Text(_l10n.retry),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardAlertData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildAlertChart(),
              ),
            ),
    );
  }
}