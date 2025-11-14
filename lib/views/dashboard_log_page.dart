import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/device_models.dart';
import '../services/device_service.dart';
import '../widgets/pie_chart_card.dart';
import '../routes/app_routes.dart';

class DashboardLogPage extends StatefulWidget {
  const DashboardLogPage({super.key});

  @override
  State<DashboardLogPage> createState() => _DashboardLogPageState();
}

class _DashboardLogPageState extends State<DashboardLogPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Dashboard> _logCountData = [];

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
    _loadDashboardLogData();
  }

  Future<void> _loadDashboardLogData() async {
    try {
      final response = await DeviceService.getDashboardDeviceLog();

      setState(() {
        _logCountData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  Widget _buildLogChart() {
    if (_logCountData.isEmpty) {
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
                _l10n.noLogData,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _logCountData.map((log) => Container(
        margin: const EdgeInsets.all(8),
        child: PieChartCard(
          title: log.label,
          total: log.total,
          primaryLabel: _l10n.report,
          primaryValue: log.data[0],
          primaryColor: Colors.green,
          secondaryLabel: _l10n.dispatch,
          secondaryValue: log.data[1],
          secondaryColor: Colors.red,
          shouldAnimate: true,
          onTap: () {
            AppRoutes.goToDeviceLog(
              context,
              log.id,
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
          _l10n.operationLogs,
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
                      _loadDashboardLogData();
                    },
                    child: Text(_l10n.retry),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardLogData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildLogChart(),
              ),
            ),
    );
  }
}