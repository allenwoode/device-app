import 'package:flutter/material.dart';
import 'package:device/config/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import 'route_component.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _selectedLanguageKey = 'zh';

  final Map<String, String> _languages = {
    'zh': '简体中文',
    'en': 'English',
  };

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
    _loadSavedLocale();
  }

  // Future<void> _loadCurrentLanguage() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedLanguageCode = prefs.getString('language_code') ?? 'zh';

  //     // Find the language name from the code
  //     String languageName = '中文'; // default
  //     for (final entry in _languages.entries) {
  //       if (entry.value == savedLanguageCode) {
  //         languageName = entry.key;
  //         break;
  //       }
  //     }

  //     setState(() {
  //       _selectedLanguage = languageName;
  //     });
  //   } catch (e) {
  //     // Default to Chinese if loading fails
  //     setState(() {
  //       _selectedLanguage = '中文';
  //     });
  //   }
  // }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            _l10n.selectLanguage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.keys.map((language) {
              return RadioListTile<String>(
                title: Text(
                  _languages[language]!,
                  style: const TextStyle(fontSize: 14),
                ),
                value: language,
                groupValue: _selectedLanguageKey,
                activeColor: AppColors.primaryColor,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguageKey = value;
                    });
                    Navigator.of(context).pop();
                    _saveLanguagePreference(value);
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _l10n.cancel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString('locale') ?? 'zh';

      if (mounted) {
        setState(() {
          _selectedLanguageKey = savedLocaleCode;
        });
      }
    } catch (e) {
      // Fallback to default locale on error
      if (mounted) {
        setState(() {
          
        });
      }
    }
  }

  Future<void> _saveLanguagePreference(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = language;

      // Save language preference to SharedPreferences
      await prefs.setString('locale', languageCode);
      //await prefs.setString('language_name', language);

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       '语言已设置为$language',
        //       style: const TextStyle(fontSize: 12),
        //     ),
        //     backgroundColor: Colors.green,
        //   ),
        // );

        // Show restart dialog to apply language changes
        //_showRestartDialog(language);
        
        // apply set to main page and effect right now
        final routeComponent = RouteComponent.of(context);
        if (routeComponent != null) {
          routeComponent.setLocale(Locale(languageCode));
        }

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       '语言已切换为$language',
        //       style: const TextStyle(fontSize: 12),
        //     ),
        //     backgroundColor: Colors.green,
        //   ),
        // );

      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _l10n.saveLanguageSettingsFailed,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          _l10n.settings,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSettingsSection(),
                ],
              ),
            ),
          ),
          _buildLogoutButton(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.language,
            title: _l10n.languageSettings,
            subtitle: _l10n.currentLanguage(_languages[_selectedLanguageKey]!),
            onTap: _showLanguageDialog,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: _l10n.notificationSettings,
            subtitle: _l10n.notificationSettingsSubtitle,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _l10n.notificationFeatureTodo,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.security,
            title: _l10n.privacySecurity,
            subtitle: _l10n.privacySecuritySubtitle,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _l10n.securityFeatureTodo,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.storage,
            title: _l10n.storageManagement,
            subtitle: _l10n.storageManagementSubtitle,
            onTap: () {
              _showClearCacheDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
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
      margin: const EdgeInsets.only(left: 76),
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      width: double.infinity,
      //height: 45,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            _l10n.clearCache,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            _l10n.clearCacheConfirm,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _l10n.cancel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCache();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _l10n.confirm,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearCache() {
    // Simulate cache clearing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _l10n.cacheCleared,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleLogout() {
    ConfirmDialog.show(
      context: context,
      title: _l10n.confirmExit,
      message: _l10n.confirmLogoutMessage,
      confirmText: _l10n.logout,
      cancelText: _l10n.cancel,
      confirmButtonColor: Colors.red,
      onConfirm: () async {
        Navigator.of(context).pop();
        await _performLogout();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await AuthService.logout();

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Navigate after showing success message
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            AppRoutes.goToLogin(context, clearStack: true);
          }
        });
      } else {
        _showStyledAlertDialog(_l10n.error, _l10n.logoutFailed);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showStyledAlertDialog(_l10n.error, _l10n.networkError);
    }
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
}