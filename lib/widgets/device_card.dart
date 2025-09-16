import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:device/models/device_models.dart';
import 'package:device/routes/app_routes.dart';

class DeviceCard extends StatelessWidget {
  final DeviceData device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRoutes.goToDeviceDetail(context, device.id, device.productId);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with server icon and WiFi status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Icon
                  _buildServerIcon(),
                  // WiFi status indicator
                  _buildStatusIcon(),
                ],
              ),
              
              const Spacer(),
              
              // Device information at bottom
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device name
                  Text(
                    device.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  // Device ID and model
                  Text(
                    '${device.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  // Device ID and model
                  Text(
                    '${device.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerIcon() {
    return Container(
      width: 68,
      height: 68,
      child: Image.asset(
        'lib/assets/images/${device.name}.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default image if specific device image not found
          return Image.asset(
            'lib/assets/images/default-device-logo.png',
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon() {
    final bool isConnected = device.state == 1;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isConnected ? Colors.green : Colors.grey[400]!,
          width: 1.5,
        ),
      ),
      child: Icon(
        isConnected ? Icons.wifi : Icons.wifi_off,
        color: isConnected ? Colors.green : Colors.grey[400],
        size: 16,
      ),
    );
  }
}