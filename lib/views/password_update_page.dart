import 'package:flutter/material.dart';
import 'package:device/config/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class PasswordUpdatePage extends StatefulWidget {
  const PasswordUpdatePage({super.key});

  @override
  State<PasswordUpdatePage> createState() => _PasswordUpdatePageState();
}

class _PasswordUpdatePageState extends State<PasswordUpdatePage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate all fields
    bool hasError = false;

    if (oldPassword.isEmpty) {
      setState(() {
        _oldPasswordError = _l10n.pleaseEnterOldPassword;
      });
      hasError = true;
    } else {
      setState(() {
        _oldPasswordError = null;
      });
    }

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = _l10n.pleaseEnterNewPassword;
      });
      hasError = true;
    } else if (newPassword.length < 6) {
      setState(() {
        _newPasswordError = _l10n.passwordTooShort;
      });
      hasError = true;
    } else {
      setState(() {
        _newPasswordError = null;
      });
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = _l10n.pleaseEnterConfirmPassword;
      });
      hasError = true;
    } else if (confirmPassword != newPassword) {
      setState(() {
        _confirmPasswordError = _l10n.passwordsDoNotMatch;
      });
      hasError = true;
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }

    if (hasError) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.updatePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _l10n.passwordUpdateSuccess,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back after success
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _l10n.passwordUpdateFailed,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          _l10n.changePassword,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _oldPasswordController,
                label: _l10n.oldPassword,
                isPasswordVisible: _oldPasswordVisible,
                errorText: _oldPasswordError,
                onVisibilityToggle: () {
                  setState(() {
                    _oldPasswordVisible = !_oldPasswordVisible;
                  });
                },
                onChanged: (value) {
                  if (_oldPasswordError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _oldPasswordError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _newPasswordController,
                label: _l10n.newPassword,
                isPasswordVisible: _newPasswordVisible,
                errorText: _newPasswordError,
                onVisibilityToggle: () {
                  setState(() {
                    _newPasswordVisible = !_newPasswordVisible;
                  });
                },
                onChanged: (value) {
                  if (_newPasswordError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _newPasswordError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: _l10n.confirmPassword,
                isPasswordVisible: _confirmPasswordVisible,
                errorText: _confirmPasswordError,
                onVisibilityToggle: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                },
                onChanged: (value) {
                  if (_confirmPasswordError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _confirmPasswordError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 40),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    required Function(String) onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: !isPasswordVisible,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: errorText != null
                    ? const BorderSide(color: Colors.red, width: 1)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: errorText != null
                    ? const BorderSide(color: Colors.red, width: 1)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : AppColors.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: onVisibilityToggle,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleUpdatePassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              _l10n.updatePassword,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
    );
  }
}
