import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:device/config/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String _version = '';
  bool _isLoading = true;

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
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _version = '1.1.0';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _l10n.networkError,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _l10n.networkError,
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
          _l10n.aboutUs,
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildAppIcon(),
                  const SizedBox(height: 20),
                  _buildAppName(),
                  const SizedBox(height: 10),
                  _buildVersionInfo(),
                  const SizedBox(height: 40),
                  _buildMenuSection(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor.withOpacity(0.1),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.device_hub,
        size: 50,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      _l10n.appTitle,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        '${_l10n.appVersion} $_version',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            title: '备案号',
            showArrow: false,
            message: 'ABN20251022889765X',
            onTap: () {}
          ),
          _buildDivider(),
          _buildMenuItem(
            title: '官网',
            showArrow: true,
            onTap: () {
              _launchURL('https://www.jama-net.com/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required bool showArrow,
    required VoidCallback onTap,
    String?  message,
    //Color? iconColor,
    //Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Row(
          children: [

            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20)
            else
              Text(
                message ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ) 
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      height: 1,
      color: Colors.grey[200],
    );
  }

}
