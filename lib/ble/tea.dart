import 'dart:convert';
import 'dart:typed_data';

/// TEA (Tiny Encryption Algorithm) Encryptor
class TeaEncryptor {
  final String key;

  TeaEncryptor(this.key) {
    if (key.length < 16) {
      throw Exception('The key must have length larger than or equal to 16');
    }
  }

  Uint8List encrypt(Uint8List plain) {
    final keyBytes = utf8.encode(key);
    final keyInts = _bytesToInts(Uint8List.fromList(keyBytes));

    final plainLength = plain.length;
    final alignedLength = (plainLength ~/ 8) * 8;
    final plainInts = _bytesToInts(Uint8List.fromList(plain.sublist(0, alignedLength)));

    final resultBuffer = BytesBuilder();

    for (int i = 0; i < plainInts.length; i += 2) {
      const int delta = 0x9e3779b9;
      int sum = 0;
      int a = plainInts[i];
      int b = plainInts[i + 1];

      for (int j = 0; j < 8; j++) {
        sum = _uint32(sum + delta);
        a = _uint32(a + (_uint32((_uint32(b << 4) + keyInts[0]) ^ (b + sum) ^ (_uint32(b >> 5) + keyInts[1]))));
        b = _uint32(b + (_uint32((_uint32(a << 4) + keyInts[2]) ^ (a + sum) ^ (_uint32(a >> 5) + keyInts[3]))));
      }

      resultBuffer.add(_intToBytes(a));
      resultBuffer.add(_intToBytes(b));
    }

    // Append remaining bytes that don't fit into 8-byte blocks
    if (alignedLength < plainLength) {
      resultBuffer.add(plain.sublist(alignedLength));
    }

    final encrypted = resultBuffer.toBytes();
    print('[encrypt]');
    print('plain: ${_bytesToHex(plain)}');
    print('key: $key');
    print('encrypted: ${_bytesToHex(encrypted)}');

    return encrypted;
  }

  Uint8List decrypt(Uint8List encrypted) {
    final keyBytes = utf8.encode(key);
    final keyInts = _bytesToInts(Uint8List.fromList(keyBytes));

    final encryptedLength = encrypted.length;
    final alignedLength = (encryptedLength ~/ 8) * 8;
    final encryptedInts = _bytesToInts(Uint8List.fromList(encrypted.sublist(0, alignedLength)));

    final resultBuffer = BytesBuilder();

    for (int i = 0; i < encryptedInts.length; i += 2) {
      const int delta = 0x9e3779b9;
      int sum = _uint32(delta << 3);
      int a = encryptedInts[i];
      int b = encryptedInts[i + 1];

      for (int j = 0; j < 8; j++) {
        b = _uint32(b - (_uint32((_uint32(a << 4) + keyInts[2]) ^ (a + sum) ^ (_uint32(a >> 5) + keyInts[3]))));
        a = _uint32(a - (_uint32((_uint32(b << 4) + keyInts[0]) ^ (b + sum) ^ (_uint32(b >> 5) + keyInts[1]))));
        sum = _uint32(sum - delta);
      }

      resultBuffer.add(_intToBytes(a));
      resultBuffer.add(_intToBytes(b));
    }

    // Append remaining bytes
    if (alignedLength < encryptedLength) {
      resultBuffer.add(encrypted.sublist(alignedLength));
    }

    final plain = resultBuffer.toBytes();
    print('[decrypt]');
    print('encrypted: ${_bytesToHex(encrypted)}');
    print('key: $key');
    print('plain: ${_bytesToHex(plain)}');

    return plain;
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }

  // Convert bytes to 32-bit integers (big-endian)
  List<int> _bytesToInts(Uint8List bytes) {
    final ints = <int>[];
    for (int i = 0; i < bytes.length; i += 4) {
      if (i + 3 < bytes.length) {
        final value = (bytes[i] << 24) |
                     (bytes[i + 1] << 16) |
                     (bytes[i + 2] << 8) |
                     bytes[i + 3];
        ints.add(_uint32(value));
      }
    }
    return ints;
  }

  // Convert 32-bit integer to bytes (big-endian)
  Uint8List _intToBytes(int value) {
    return Uint8List.fromList([
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ]);
  }

  // Ensure unsigned 32-bit integer
  int _uint32(int value) {
    return value & 0xFFFFFFFF;
  }
}