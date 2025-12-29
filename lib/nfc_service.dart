import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {

  /// Check NFC availability
  static Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  /// Read NFC Tag
  static Future<void> readTag({
    required Function(String) onData,
    required Function(String) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            onError("No NDEF data found");
            NfcManager.instance.stopSession();
            return;
          }

          final record = ndef.cachedMessage!.records.first;
          final payload = utf8.decode(record.payload.skip(3).toList());
          onData(payload);

          NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Write NFC Tag
  static Future<void> writeTag({
    required String text,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            onError("Tag not writable");
            NfcManager.instance.stopSession();
            return;
          }

          final message = NdefMessage([
            NdefRecord.createText(text),
          ]);

          await ndef.write(message);
          onSuccess("Write successful");

          NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }
}
