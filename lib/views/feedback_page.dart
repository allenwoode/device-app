import 'dart:convert';

import 'package:device/models/login_models.dart';
import 'package:device/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:device/config/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../services/device_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _selectedFeedbackType = 'feature';
  bool _isSubmitting = false;
  String? _feedbackError;
  User? _currentUser;

  final List<String> _feedbackTypes = [
    'feature',
    'bug',
    'question',
    'other'
  ];

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfoString = await StorageService.getUserInfo();
      if (userInfoString != null) {
        final userJson = jsonDecode(userInfoString);
        setState(() {
          _currentUser = User.fromJson(userJson);
        });
      }
    } catch (e) {
      print('load user info error: $e');
    }
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    final contact = _contactController.text.trim();

    if (feedback.isEmpty) {
      setState(() {
        _feedbackError = _l10n.pleaseFillFeedback;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackError = null;
    });

    try {
      // Submit feedback via DeviceService
      final success = await DeviceService.submitFeedback(
        type: _selectedFeedbackType,
        email: contact,
        content: feedback,
        company: _currentUser?.orgName ?? '',
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          _feedbackController.clear();
          // _contactController.clear();
          // setState(() {
          //   _selectedFeedbackType = 'feature';
          // });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.feedbackSubmitSuccess, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Feedback submission failed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.feedbackSubmitFailed, style: const TextStyle(fontSize: 12)),
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
          _l10n.feedback,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildFeedbackTypeSection(),
            const SizedBox(height: 20),
            _buildFeedbackContentSection(),
            const SizedBox(height: 20),
            _buildContactSection(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTypeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        //borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.feedbackType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _feedbackTypes.map((typeKey) {
              final isSelected = _selectedFeedbackType == typeKey;
              String typeText;
              switch (typeKey) {
                case 'feature':
                  typeText = _l10n.featureSuggestion;
                  break;
                case 'bug':
                  typeText = _l10n.bugReport;
                  break;
                case 'question':
                  typeText = _l10n.usageQuestion;
                  break;
                case 'other':
                  typeText = _l10n.other;
                  break;
                default:
                  typeText = typeKey;
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFeedbackType = typeKey;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    typeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackContentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        //borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.feedbackContent,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 6,
            onChanged: (value) {
              if (_feedbackError != null && value.trim().isNotEmpty) {
                setState(() {
                  _feedbackError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: _l10n.feedbackHint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
              errorText: _feedbackError,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        //borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.contactInfo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactController,
            decoration: InputDecoration(
              hintText: _l10n.contactHint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _l10n.contactHelpText,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _l10n.submitFeedback,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}