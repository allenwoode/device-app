import 'dart:typed_data';
import 'dart:convert';

import 'package:device/api/api_config.dart';
import 'package:device/l10n/app_localizations.dart';
import 'package:device/services/api_interceptor.dart';
import 'package:device/services/auth_service.dart';
import 'package:device/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;
  // String? _selectedGender;
  Uint8List? _selectedAvatarBytes;
  String _originalName = '';
  String _originalEmail = '';
  String _originalPhone = '';
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
    _loadUserDetail();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetail() async {
    try {
      final result = await AuthService.getUserDetail();

      if (!mounted) {
        return;
      }

      final name = (result['name'] ?? '').toString();
      final email = (result['email'] ?? '').toString();
      final phone = (result['telephone'] ?? '').toString();
      // final genderValue =
      //     ((result['gender'] as Map<String, dynamic>?)?['value'] ?? '')
      //       .toString()
      //       .toLowerCase();

      _nameController.text = name;
      _emailController.text = email;
      _phoneController.text = phone;

      setState(() {
        _user = result;
        _isLoading = false;
        _errorMessage = null;
        _originalName = name;
        _originalEmail = email;
        _originalPhone = phone;
        // _selectedGender =
        //     genderValue == 'male' || genderValue == 'female' ? genderValue : null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _pickAvatarFromGallery() async {
    if (_isUploadingAvatar) {
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingAvatar = true;
        _selectedAvatarBytes = bytes;
      });

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pickedFile.path,
          filename: pickedFile.name,
        ),
      });

      final response = await ApiInterceptor.post(
        '${ApiConfig.baseUrl}/file/upload',
        data: formData,
      ).timeout(ApiConfig.timeout);

      final data = response.data;
      if (response.statusCode != 200 || data is! Map<String, dynamic>) {
        throw Exception(_l10n.failed);
      }

      if (data['status'] != 200) {
        throw Exception(data['message']?.toString() ?? _l10n.failed);
      }

      final accessUrl =
          ((data['result'] as Map<String, dynamic>?)?['accessUrl'] ?? '')
              .toString();

      if (accessUrl.isEmpty) {
        throw Exception(_l10n.failed);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingAvatar = false;
        _selectedAvatarBytes = null;
        _user = {
          ...?_user,
          'avatar': accessUrl,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.success)),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingAvatar = false;
        _selectedAvatarBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is DioException ? (e.message ?? _l10n.avatarPickFailed) : _l10n.avatarPickFailed),
        ),
      );
    }
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionInfoTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 18, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  String _getOrganizationName() {
    final orgList = _user?['orgList'];
    if (orgList is List && orgList.isNotEmpty && orgList.first is Map<String, dynamic>) {
      return (orgList.first['name'] ?? '').toString();
    }
    return '';
  }

  String _getOrganizationId() {
    final orgList = _user?['orgList'];
    if (orgList is List && orgList.isNotEmpty && orgList.first is Map<String, dynamic>) {
      return (orgList.first['id'] ?? '').toString();
    }
    return '';
  }

  // List<Map<String, dynamic>> _extractOrganizations(dynamic data) {
  //   if (data is Map<String, dynamic>) {
  //     final result = data['result'];
  //     if (result is List) {
  //       return result.whereType<Map<String, dynamic>>().toList();
  //     }

  //     if (result is Map<String, dynamic>) {
  //       final listData = result['data'];
  //       if (listData is List) {
  //         return listData.whereType<Map<String, dynamic>>().toList();
  //       }
  //     }
  //   }
  //   return <Map<String, dynamic>>[];
  // }

  // Future<List<Map<String, dynamic>>> _searchOrganizations(String keyword) async {
  //   try {
  //     final trimmedKeyword = keyword.trim();
  //     final requestBody = {
  //       'sorts': [
  //         {'name': 'level', 'order': 'asc'},
  //       ],
  //       'terms': trimmedKeyword.isEmpty
  //           ? []
  //           : [
  //               {
  //                 'column': 'name',
  //                 'termType': 'like',
  //                 'value': '%$trimmedKeyword%',
  //               },
  //             ],
  //     };

  //     final response = await ApiInterceptor.post(
  //       '${ApiConfig.baseUrl}/organization/_all',
  //       data: requestBody,
  //     ).timeout(ApiConfig.timeout);

  //     final responseData = response.data;
  //     if (response.statusCode == 200 &&
  //         responseData is Map<String, dynamic> &&
  //         responseData['status'] == 200) {
  //       final organizations = _extractOrganizations(response.data);
  //       if (organizations.isNotEmpty) {
  //         return organizations;
  //       }
  //     }
  //   } catch (_) {}

  //   final orgList = _user?['orgList'];
  //   if (orgList is List) {
  //     final local = orgList.whereType<Map<String, dynamic>>().toList();
  //     if (keyword.trim().isEmpty) {
  //       return local;
  //     }
  //     return local
  //         .where(
  //           (org) => (org['name'] ?? '')
  //               .toString()
  //               .toLowerCase()
  //               .contains(keyword.trim().toLowerCase()),
  //         )
  //         .toList();
  //   }

  //   return <Map<String, dynamic>>[];
  // }

  // Future<void> _showOrganizationDialog() async {
  //   final result = await showDialog<Map<String, String>>(
  //     context: context,
  //     builder: (_) => _OrganizationSearchDialog(
  //       initialName: _getOrganizationName(),
  //       title: _l10n.organization,
  //       emptyText: _l10n.organizationUnitEmpty,
  //       cancelText: _l10n.cancel,
  //       confirmText: _l10n.confirm,
  //       requiredErrorText: _l10n.organization,
  //       searchOrganizations: _searchOrganizations,
  //     ),
  //   );

  //   if (result == null || !mounted) {
  //     return;
  //   }

  //   final selectedOrgName = (result['orgName'] ?? '').trim();
  //   final selectedOrgId = (result['orgId'] ?? '').trim();
  //   if (selectedOrgName.isEmpty || selectedOrgId.isEmpty) {
  //     return;
  //   }
  //   final currentUser = _user ?? <String, dynamic>{};
  //   final currentOrgList = currentUser['orgList'];
  //   List<dynamic> updatedOrgList;

  //   if (currentOrgList is List && currentOrgList.isNotEmpty) {
  //     updatedOrgList = List<dynamic>.from(currentOrgList);
  //     if (updatedOrgList.first is Map<String, dynamic>) {
  //       updatedOrgList[0] = {
  //         ...(updatedOrgList.first as Map<String, dynamic>),
  //         'name': selectedOrgName,
  //         'id': selectedOrgId.isNotEmpty
  //             ? selectedOrgId
  //             : ((updatedOrgList.first as Map<String, dynamic>)['id'] ?? '').toString(),
  //       };
  //     }
  //   } else {
  //     updatedOrgList = [
  //       {'id': selectedOrgId, 'name': selectedOrgName},
  //     ];
  //   }

  //   setState(() {
  //     _user = {
  //       ...currentUser,
  //       'orgList': updatedOrgList,
  //     };
  //   });
  // }

  Future<void> _handleSave() async {
    if (_isSaving) {
      return;
    }

    final userId = (_user?['id'] ?? '').toString();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.userDetailLoadFailed)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AuthService.updateUserDetail(
        id: userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatar: (_user?['avatar'] ?? '').toString(),
        telephone: _phoneController.text.trim(),
        orgId: _getOrganizationId(),
        orgName: _getOrganizationName(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _originalName = _nameController.text.trim();
        _originalEmail = _emailController.text.trim();
        _originalPhone = _phoneController.text.trim();
        _user = {
          ...?_user,
          'name': _originalName,
          'email': _originalEmail,
          'phone': _originalPhone,
          'telephone': _originalPhone,
        };
      });

      final localUserInfoString = await StorageService.getUserInfo();
      Map<String, dynamic> mergedUserInfo = {};

      if (localUserInfoString != null && localUserInfoString.isNotEmpty) {
        try {
          final decoded = jsonDecode(localUserInfoString);
          if (decoded is Map<String, dynamic>) {
            mergedUserInfo = decoded;
          }
        } catch (_) {}
      }

      mergedUserInfo = {
        ...mergedUserInfo,
        ...?_user,
        'id': userId,
        'name': _originalName,
        'email': _originalEmail,
        'avatar': (_user?['avatar'] ?? '').toString(),
        'telephone': _originalPhone,
        'phone': _originalPhone,
        'orgId': _getOrganizationId(),
        'orgName': _getOrganizationName(),
      };

      await StorageService.saveUserInfo(jsonEncode(mergedUserInfo));

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(_l10n.success)),
      // );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', '').isNotEmpty
                ? e.toString().replaceFirst('Exception: ', '')
                : _l10n.networkError,
          ),
        ),
      );
    }

    // navigate back to mine page and refresh user info
    Navigator.of(context).pop();
  }

  Widget _buildEditableField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String originalValue,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildGenderField() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(color: Colors.grey[200]!),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         SizedBox(
  //           width: 120,
  //           child: Text(
  //             _l10n.genderLabel,
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey[700],
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               Flexible(
  //                 child: RadioListTile<String>(
  //                   value: 'male',
  //                   groupValue: _selectedGender,
  //                   dense: true,
  //                   contentPadding: EdgeInsets.zero,
  //                   visualDensity: VisualDensity.compact,
  //                   title: Text(_l10n.male, style: const TextStyle(fontSize: 14)),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       _selectedGender = value;
  //                     });
  //                   },
  //                 ),
  //               ),
  //               Flexible(
  //                 child: RadioListTile<String>(
  //                   value: 'female',
  //                   groupValue: _selectedGender,
  //                   dense: true,
  //                   contentPadding: EdgeInsets.zero,
  //                   visualDensity: VisualDensity.compact,
  //                   title: Text(_l10n.female, style: const TextStyle(fontSize: 14)),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       _selectedGender = value;
  //                     });
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAvatarSection() {
    final avatarUrl = (_user?['avatar'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _pickAvatarFromGallery,
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedAvatarBytes != null
                      ? Image.memory(
                          _selectedAvatarBytes!,
                          fit: BoxFit.cover,
                        )
                      : avatarUrl.isEmpty
                          ? Icon(Icons.person, size: 44, color: Colors.grey[500])
                          : Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, size: 44, color: Colors.grey[500]);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _l10n.tapToChangeAvatar,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
          _l10n.userInfo,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading || _user == null || _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                  _l10n.save,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Text(
                    _errorMessage ?? _l10n.userDetailLoadFailed,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAvatarSection(),
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            _buildEditableField(
                              label: _l10n.nameLabel,
                              hint: _l10n.nameHint,
                              controller: _nameController,
                              originalValue: _originalName,
                            ),
                            //_buildInfoTile(_l10n.username, (_user?['username'] ?? '').toString()),
                            _buildEditableField(
                              label: _l10n.emailLabel,
                              hint: _l10n.emailHint,
                              controller: _emailController,
                              originalValue: _originalEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _buildEditableField(
                              label: _l10n.phoneLabel,
                              hint: _l10n.phoneHint,
                              controller: _phoneController,
                              originalValue: _originalPhone,
                              keyboardType: TextInputType.phone,
                            ),
                            //_buildGenderField(),
                            //_buildInfoTile('Status', (_user?['status'] ?? '').toString()),
                            //_buildInfoTile(_l10n.registrationTime, _formatCreateTime(_user?['createTime'])),
                            //_buildInfoTile('ID', (_user?['id'] ?? '').toString()),
                            //_buildInfoTile('${_l10n.role}', (_user?['roleList'] != null && (_user!['roleList'] as List).isNotEmpty) ? (_user!['roleList'][0]['name'] ?? '') : _l10n.userRoleEmpty),
                            // _buildActionInfoTile(
                            //   label: _l10n.organization,
                            //   value: _getOrganizationName().isNotEmpty
                            //       ? _getOrganizationName()
                            //       : _l10n.organizationUnitEmpty,
                            //   onTap: _showOrganizationDialog,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// class _OrganizationSearchDialog extends StatefulWidget {
//   const _OrganizationSearchDialog({
//     required this.initialName,
//     required this.title,
//     required this.emptyText,
//     required this.cancelText,
//     required this.confirmText,
//     required this.requiredErrorText,
//     required this.searchOrganizations,
//   });

//   final String initialName;
//   final String title;
//   final String emptyText;
//   final String cancelText;
//   final String confirmText;
//   final String requiredErrorText;
//   final Future<List<Map<String, dynamic>>> Function(String keyword)
//   searchOrganizations;

//   @override
//   State<_OrganizationSearchDialog> createState() =>
//       _OrganizationSearchDialogState();
// }

// class _OrganizationSearchDialogState extends State<_OrganizationSearchDialog> {
//   late final TextEditingController _controller;
//   List<Map<String, dynamic>> _results = [];
//   bool _isSearching = false;
//   String? _inputError;
//   int _requestToken = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.initialName);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _runSearch(String keyword) async {
//     final currentToken = ++_requestToken;
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _isSearching = true;
//     });

//     final results = await widget.searchOrganizations(keyword);
//     if (!mounted || currentToken != _requestToken) {
//       return;
//     }

//     setState(() {
//       _results = results;
//       _isSearching = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.white,
//       title: Text(
//         widget.title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//       ),
//       content: SizedBox(
//         width: 320,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _controller,
//               autofocus: true,
//               onChanged: (value) {
//                 if (_inputError != null && value.trim().isNotEmpty) {
//                   setState(() {
//                     _inputError = null;
//                   });
//                 }
//                 _runSearch(value);
//               },
//               decoration: InputDecoration(
//                 hintText: widget.title,
//                 border: const OutlineInputBorder(),
//                 isDense: true,
//                 errorText: _inputError,
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () {
//                     if (_controller.text.trim().isEmpty) {
//                       setState(() {
//                         _inputError = widget.requiredErrorText;
//                       });
//                       return;
//                     }
//                     _runSearch(_controller.text);
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 220,
//               child: _isSearching
//                   ? const Center(child: CircularProgressIndicator())
//                   : _results.isEmpty
//                   ? Center(
//                       child: Text(
//                         widget.emptyText,
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       ),
//                     )
//                   : ListView.separated(
//                       itemCount: _results.length,
//                       separatorBuilder: (_, __) => Divider(
//                         height: 1,
//                         color: Colors.grey[200],
//                       ),
//                       itemBuilder: (context, index) {
//                         final item = _results[index];
//                         final name = (item['name'] ?? '').toString();
//                         final id = (item['id'] ?? '').toString();
//                         return ListTile(
//                           dense: true,
//                           title: Text(
//                             name,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           onTap: () => Navigator.of(context).pop({
//                             'orgId': id,
//                             'orgName': name,
//                           }),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: Text(widget.cancelText),
//         ),
//         TextButton(
//           onPressed: () {
//             if (_controller.text.trim().isEmpty) {
//               setState(() {
//                 _inputError = widget.requiredErrorText;
//               });
//               return;
//             }
//             Navigator.of(context).pop({
//               'orgId': '',
//               'orgName': _controller.text.trim(),
//             });
//           },
//           child: Text(widget.confirmText),
//         ),
//       ],
//     );
//   }
// }
