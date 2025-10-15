import 'dart:typed_data';

import 'package:device/ble/tea.dart';

/// Device response frame assembler
class BleDeviceResponseFrames {
  final Map<int, Uint8List> _frames = {};
  int _totalFrames = 0;
  bool _isCompleted = false;

  void addFrame(Uint8List data) {
    // Expect caller to validate, but double-check anyway
    if (data.length < 3) {
      print('ResponseFrames: Frame too short (${data.length} bytes)');
      return;
    }

    final frameNumber = data[0];
    final totalFrames = data[1];
    final dataLength = data[2];

    if (dataLength != data.length - 3) {
      print('ResponseFrames: Data length mismatch - header says $dataLength but got ${data.length - 3}');
      return;
    }

    _totalFrames = totalFrames;
    _frames[frameNumber] = Uint8List.fromList(data.sublist(3));

    print('ResponseFrames: Stored frame $frameNumber/$totalFrames (${dataLength} bytes payload)');
    print('  Progress: ${_frames.length}/$_totalFrames frames received');

    if (_frames.length == _totalFrames) {
      _isCompleted = true;
      print('ResponseFrames: All frames received, ready to decrypt...');
    }
  }

  bool get isCompleted => _isCompleted;

  Uint8List unpackAndDecryptFrames(TeaEncryptor encryptor) {
    if (!_isCompleted) {
      throw Exception('Not all frames received');
    }

    final buffer = BytesBuilder();
    for (int i = 1; i <= _totalFrames; i++) {
      if (!_frames.containsKey(i)) {
        throw Exception('Missing frame $i');
      }
      buffer.add(_frames[i]!);
    }

    Uint8List encrypted = buffer.toBytes();
    if ((encrypted[0] & 0xFF) == 0xFE) {
      encrypted = encrypted.sublist(2);
    }
    print('Encrypted response data: ${_bytesToHex(encrypted)}');

    final decrypted = encryptor.decrypt(encrypted);
    print('Decrypted response data: ${_bytesToHex(decrypted)}');

    return decrypted;
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }
}