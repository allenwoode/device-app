import 'package:flutter/material.dart';
import 'package:device/models/device_models.dart';
import 'package:device/widgets/device_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';

class DeviceSearchPage extends StatefulWidget {
  final List<DeviceData> allDevices;

  const DeviceSearchPage({
    super.key,
    required this.allDevices,
  });

  @override
  State<DeviceSearchPage> createState() => _DeviceSearchPageState();
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DeviceData> _filteredDevices = [];

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
    _filteredDevices = widget.allDevices;
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDevices = widget.allDevices;
      } else {
        _filteredDevices = widget.allDevices.where((device) {
          return device.id.toLowerCase().contains(query) ||
                 device.name.toLowerCase().contains(query);
        }).toList();
      }
    });
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
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: _l10n.searchDeviceHint,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(13),
            ),
            onChanged: (value) {
              setState(() {
                // Trigger rebuild to update suffixIcon
              });
            },
          ),
        ),
      ),
      body: _filteredDevices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? _l10n.searchDeviceHint
                        : _l10n.noDeviceData,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _filteredDevices.length,
              itemBuilder: (context, index) {
                return DeviceCard(device: _filteredDevices[index]);
              },
            ),
    );
  }
}
