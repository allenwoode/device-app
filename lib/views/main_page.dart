import 'package:flutter/material.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
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
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: _l10n.iot,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: _l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: _l10n.mine,
          ),
        ],
      ),
    );
  }
}
