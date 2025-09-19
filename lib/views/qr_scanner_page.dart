import 'package:device/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/device_service.dart';
import '../widgets/confirm_dialog.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  AppLocalizations get _l10n {
    try {
      return AppLocalizations.of(context)!;
    } catch (e) {
      return lookupAppLocalizations(const Locale('zh'));
    }
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          SimpleAlertDialog.show(
            context: context,
            title: _l10n.permissionInsufficient,
            message: _l10n.cameraPermissionRequired,
            onConfirm: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        }
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isProcessing && mounted && capture.barcodes.isNotEmpty) {
      final String? code = capture.barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isProcessing = true;
        });
        _handleScannedCode(code);
      }
    }
  }

  Future<void> _handleScannedCode(String? code) async {
    if (code == null || code.isEmpty) {
      _resetScanning();
      return;
    }

    // Stop the camera while processing
    await cameraController.stop();

    try {
      if (mounted) {
        await _bindDevice(code);
      } else {
        _resetScanning();
      }
    } catch (e) {
      _resetScanning();
    }
  }

  Future<void> _bindDevice(String deviceId) async {
    if (!mounted) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(_l10n.bindingDevice),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final success = await DeviceService.bindDevice(deviceId: deviceId);

      // Hide loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (success) {
          AppRoutes.goToMain(context);
        } else {
          // Show error dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.bindFailed, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.bindOperationFailed, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.red,
            ),
          );
       }
    }
  }

  void _resetScanning() {
    setState(() {
      _isProcessing = false;
    });
    cameraController.start();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _l10n.scanDeviceQRCode,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () async {
              await cameraController.toggleTorch();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                // Custom overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: CustomPaint(
                    painter: ScannerOverlay(
                      borderColor: AppColors.primaryColor,
                      borderWidth: 4,
                      borderLength: 30,
                    ),
                    size: Size.infinite,
                  ),
                ),
                // Scanning indicator
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _l10n.processing,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _l10n.scanInstructions,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _l10n.scanHint,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;

  ScannerOverlay({
    required this.borderColor,
    required this.borderWidth,
    required this.borderLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final double scanAreaSize = 300;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    // Draw corner borders
    // Top-left corner
    canvas.drawLine(Offset(left, top), Offset(left + borderLength, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + borderLength), paint);

    // Top-right corner
    canvas.drawLine(Offset(right - borderLength, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + borderLength), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, bottom - borderLength), Offset(left, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + borderLength, bottom), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(right - borderLength, bottom), Offset(right, bottom), paint);
    canvas.drawLine(Offset(right, bottom - borderLength), Offset(right, bottom), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}