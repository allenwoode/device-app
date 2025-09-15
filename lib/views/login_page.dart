import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import 'main_page.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _checkingLoginState = true;
  bool _obscurePassword = true;
  Locale _selectedLocale = const Locale('zh');

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingLogin() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn && mounted) {
        // User is already logged in with valid token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
        return;
      }
    } catch (e) {
      print('Error checking login state: $e');
    } finally {
      if (mounted) {
        setState(() {
          _checkingLoginState = false;
        });
      }
    }
  }

  void _showResetPasswordModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModalOption(
              text: _l10n.resetPassword,
              onTap: () {
                Navigator.pop(context);
                // Handle reset password
              },
            ),
            const SizedBox(height: 32),
            _buildModalOption(
              text: _l10n.accountAppeal,
              onTap: () {
                Navigator.pop(context);
                // Handle account appeal
              },
            ),
            const SizedBox(height: 32),
            _buildModalOption(
              text: _l10n.cancel,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalOption({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final loginResponse = await AuthService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        if (loginResponse != null && loginResponse.status == 200) {
          // Login successful
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(_l10n.welcome.replaceAll('{name}', loginResponse.result.user.name)),
          //     backgroundColor: Colors.green,
          //   ),
          // );

          // Navigate to main page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
          );
        } else {
          // Login failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.loginFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Network or other error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.networkError),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLoginState) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _l10n.checkingLoginState,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Text(
                  _l10n.passwordLogin,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 60),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: _l10n.pleaseEnterUsername,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _l10n.pleaseEnterUsername;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: _l10n.pleaseEnterPassword,
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _l10n.pleaseEnterPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showResetPasswordModal,
                    child: Text(
                      _l10n.loginProblem,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Locale>(
                          value: _selectedLocale,
                          icon: const Icon(Icons.language, size: 16),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          onChanged: (Locale? newLocale) {
                            if (newLocale != null) {
                              setState(() {
                                _selectedLocale = newLocale;
                              });
                              // Update app locale
                              _updateLocale(newLocale);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: Locale('zh'),
                              child: Text('中文'),
                            ),
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _l10n.loginButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateLocale(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    // Update the app's locale
    final myApp = MyApp.of(context);
    myApp?.setLocale(locale);
  }

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      // Fallback when context is not ready
      return _selectedLocale.languageCode == 'en' 
          ? lookupAppLocalizations(const Locale('en'))
          : lookupAppLocalizations(const Locale('zh'));
    }
  }
}