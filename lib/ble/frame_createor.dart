import 'dart:convert';
import 'dart:typed_data';

import 'package:device/ble/crc.dart';
import 'package:device/ble/tea.dart';

/// BLE Linking Request Frame Creator
class LinkingRequestFrameCreator {
  static List<Uint8List> createConfigFrames(
    TeaEncryptor encryptor,
    String ssid,
    String password,
    String userData,
  ) {
    final ssidBytes = ssid.isEmpty ? Uint8List(0) : Uint8List.fromList(utf8.encode(ssid));
    final passwordBytes = password.isEmpty ? Uint8List(0) : Uint8List.fromList(utf8.encode(password));
    final userDataBytes = userData.isEmpty ? Uint8List(0) : Uint8List.fromList(utf8.encode(userData));

    //final length = ssidBytes.length + passwordBytes.length + userDataBytes.length + 4;
    final buffer = BytesBuilder();

    // Add SSID length and data
    buffer.addByte(ssidBytes.length & 0xFF);
    if (ssidBytes.isNotEmpty) {
      buffer.add(ssidBytes);
    }

    // Add password length and data
    buffer.addByte(passwordBytes.length & 0xFF);
    if (passwordBytes.isNotEmpty) {
      buffer.add(passwordBytes);
    }

    // Add user data length and data
    buffer.addByte(userDataBytes.length & 0xFF);
    if (userDataBytes.isNotEmpty) {
      buffer.add(userDataBytes);
    }

    final data = buffer.toBytes();

    // Calculate CRC8 on all data except the last byte (which will be the CRC)
    final toCrc = Uint8List.fromList(data);
    final crc = CRC8.crc8Maxim(toCrc);

    // Append CRC
    buffer.addByte(crc);
    final dataWithCrc = buffer.toBytes();

    //print('Data before encryption (with CRC): ${_bytesToHex(dataWithCrc)}');

    // Encrypt the data
    final encrypted = encryptor.encrypt(dataWithCrc);

    // Create frames
    final frames = _createFrames(encrypted);

    // Print frames
    // for (int i = 0; i < frames.length; i++) {
    //   print('createConfigFrames: NO.${i + 1}->${_bytesToHex(frames[i])}');
    // }

    return frames;
  }

  static List<Uint8List> _createFrames(Uint8List data) {
    final dataLength = data.length;
    int frameCount = dataLength ~/ 17;
    if (dataLength % 17 != 0) {
      frameCount++;
    }

    int position = 0;
    final frames = <Uint8List>[];

    for (int i = 0; i < frameCount; i++) {
      final frameDataLength = (dataLength - position) < 17 ? (dataLength - position) : 17;
      final frame = Uint8List(frameDataLength + 3);

      // Frame header
      frame[0] = (i + 1) & 0xFF;           // Frame number (1-based)
      frame[1] = frameCount & 0xFF;         // Total frame count
      frame[2] = frameDataLength & 0xFF;    // Data length in this frame

      // Frame data
      for (int j = 0; j < frameDataLength; j++) {
        frame[3 + j] = data[position + j];
      }

      frames.add(frame);
      position += frameDataLength;
    }

    return frames;
  }

  // static String _bytesToHex(Uint8List bytes) {
  //   return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  // }
}