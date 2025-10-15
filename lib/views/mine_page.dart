import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/storage_service.dart';
import '../models/login_models.dart';
import '../l10n/app_localizations.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  User? _currentUser;
  bool _isLoading = true;
  //bool _isLoggingOut = false;

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
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfoString = await StorageService.getUserInfo();

      if (userInfoString != null) {
        final userJson = jsonDecode(userInfoString);
        setState(() {
          _currentUser = User.fromJson(userJson);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _handleVersionUpdate() {
    _showStyledAlertDialog(_l10n.versionUpdate, _l10n.versionUpdateTodo);
  }

  void _handleAboutUs() {
    _showStyledAlertDialog(_l10n.aboutUs, _l10n.aboutUsTodo);
  }

  void _showStyledAlertDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _l10n.confirm,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 30),
                    _buildMenuSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${_currentUser?.name ?? _l10n.user}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _currentUser?.roleList.isNotEmpty == true
                            ? _currentUser?.roleList.first.name ?? ''
                            : '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _currentUser?.orgName ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.bluetooth,
            title: _l10n.deviceConnector,
            showArrow: true,
            onTap: () {
              AppRoutes.goToDeviceConnector(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.devices_outlined,
            //iconColor: Colors.blue,
            //backgroundColor: Colors.blue.withOpacity(0.1),
            title: _l10n.deviceManagement,
            showArrow: true,
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => const DeviceManagerPage(),
              //   ),
              // );
              AppRoutes.goToDeviceManager(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.feedback_outlined,
            //iconColor: Colors.orange,
            //backgroundColor: Colors.orange.withOpacity(0.1),
            title: _l10n.feedback,
            showArrow: true,
            onTap: () {
              AppRoutes.goToFeedback(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.system_update_outlined,
            //iconColor: Colors.green,
            //backgroundColor: Colors.green.withOpacity(0.1),
            title: _l10n.versionUpdate,
            showArrow: true,
            onTap: _handleVersionUpdate,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            //iconColor: Colors.purple,
            //backgroundColor: Colors.purple.withOpacity(0.1),
            title: _l10n.aboutUs,
            showArrow: true,
            onTap: _handleAboutUs,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings,
            //iconColor: Colors.grey[700]!,
            //backgroundColor: Colors.grey.withOpacity(0.1),
            title: _l10n.settings,
            showArrow: true,
            onTap: () {
              AppRoutes.goToSettings(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool showArrow,
    required VoidCallback onTap,
    //Color? iconColor,
    //Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //color: backgroundColor ?? Colors.grey[300],
              ),
              child: Icon(
                icon,
                size: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 59),
      height: 1,
      color: Colors.grey[200],
    );
  }

}
