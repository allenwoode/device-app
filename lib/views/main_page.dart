import 'package:device/events/event_bus.dart';
import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'device_page.dart';
import 'mine_page.dart';
import 'dashboard_page.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

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
    _setupEventListeners();
  }

  void _setupEventListeners() {
    EventBus.instance.addListener(EventKeys.logout, () {
      EventBus.instance.removeListener(EventKeys.logout);
      AppRoutes.goToLogin(context);
    });
  }

  @override
  void dispose() {
    EventBus.instance.removeListener(EventKeys.logout);
    super.dispose();
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DevicePage();
      case 1:
        return const DashboardPage();
      case 2:
        return const MinePage();
      default:
        return const DevicePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      // appBar: _selectedIndex == 2 ? null : AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   title: Text(
      //     '浙江杰马电子科技',
      //     style: const TextStyle(
      //       color: Colors.black,
      //       fontSize: 16,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: false,
      // ),
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.house, size: 20),
            activeIcon: const FaIcon(FontAwesomeIcons.solidHouse, size: 20),
            label: _l10n.iot,
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.chartPie, size: 20),
            activeIcon: const FaIcon(FontAwesomeIcons.chartPie, size: 20),
            label: _l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.user, size: 20),
            activeIcon: const FaIcon(FontAwesomeIcons.solidUser, size: 20),
            label: _l10n.mine,
          ),
        ],
      ),
    );
  }
}
