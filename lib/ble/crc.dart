import 'dart:typed_data';

/// CRC-8/MAXIM calculator
/// Poly: 0x31, Init: 0x00, Refin: True, Refout: True, Xorout: 0x00
class CRC8 {
  static int crc8Maxim(Uint8List data) {
    int crc = 0;

    for (int i = 0; i < data.length; i++) {
      crc ^= data[i];

      for (int j = 0; j < 8; j++) {
        if ((crc & 0x01) == 0x01) {
          crc = (crc & 0xff) >> 1;
          crc ^= 0x8C;
        } else {
          crc = (crc & 0xff) >> 1;
        }
      }
    }

    return crc & 0xFF;
  }
}