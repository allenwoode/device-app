import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
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
  bool _isLoggingOut = false;

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

  void _do() {
    print('==========================> auth expiered');
    // Fire unauthorized event
    //EventBusService.fire(UnauthorizedEvent('Authentication expired'));
    AppRoutes.goToLogin(context, clearStack: true);
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.confirmExit),
        content: Text(_l10n.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: _isLoggingOut ? null : () async {
              setState(() {
                _isLoggingOut = true;
              });

              try {
                Navigator.pop(context);
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                final success = await AuthService.logout();
                
                // Close loading dialog
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_l10n.logoutSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  AppRoutes.goToLogin(context, clearStack: true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_l10n.logoutFailed),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog if still open
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_l10n.networkError),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoggingOut = false;
                  });
                }
              }
            },
            child: _isLoggingOut 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_l10n.confirm, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleVersionUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_l10n.versionUpdateTodo)),
    );
  }

  void _handleAboutUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_l10n.aboutUsTodo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
            _buildLogoutButton(),
            const SizedBox(height: 30),
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
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.grey[600],
            ),
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
                const SizedBox(height: 5),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
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
            icon: Icons.business,
            title: _currentUser?.orgList.isNotEmpty == true
                ? _currentUser?.orgList.first.name ?? _l10n.organizationUnitEmpty
                : _l10n.organizationUnitEmpty,
            showArrow: false,
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: _currentUser?.roleList.isNotEmpty == true
                ? _currentUser?.roleList.first.name ?? _l10n.userRoleEmpty
                : _l10n.userRoleEmpty,
            showArrow: false,
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.system_update,
            title: _l10n.versionUpdate,
            showArrow: true,
            onTap: _handleVersionUpdate,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: _l10n.aboutUs,
            showArrow: true,
            onTap: _handleAboutUs,
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Icon(
                icon,
                size: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
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

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _l10n.logout,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}