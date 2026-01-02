import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const NfcHome(),
    );
  }
}

enum NfcMode { read, write }

class NfcHome extends StatefulWidget {
  const NfcHome({super.key});

  @override
  State<NfcHome> createState() => _NfcHomeState();
}

class _NfcHomeState extends State<NfcHome> {
  NfcMode mode = NfcMode.read;
  bool isScanning = false;
  String status = "Ready to scan NFC";
  final TextEditingController writeController = TextEditingController();

  @override
  void dispose() {
    writeController.dispose();
    super.dispose();
  }

  Future<void> startNfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() => status = "NFC not available on this device");
      return;
    }

    setState(() {
      isScanning = true;
      status = "Hold phone near NFC tag...";
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          if (mode == NfcMode.read) {
            final ndef = Ndef.from(tag);
            if (ndef == null || ndef.cachedMessage == null) {
              setState(() => status = "No NDEF data found");
            } else {
              final record = ndef.cachedMessage!.records.first;
              final payload = String.fromCharCodes(record.payload.skip(3));
              setState(() => status = "Read Success:\n$payload");
              HapticFeedback.mediumImpact();
              openIfUrl(payload);
            }
          } else {
            final ndef = Ndef.from(tag);
            if (ndef == null || !ndef.isWritable) {
              setState(() => status = "Tag not writable");
            } else {
              final message = NdefMessage([
                NdefRecord.createText(writeController.text),
              ]);
              await ndef.write(message);
              setState(() => status = "Write successful");
              HapticFeedback.mediumImpact();
            }
          }
        } catch (e) {
          setState(() => status = "Error: $e");
        } finally {
          isScanning = false;
          NfcManager.instance.stopSession();
          setState(() {});
        }
      },
    );
  }

  void openIfUrl(String data) async {
    if (data.startsWith("http") || data.startsWith("upi://")) {
      final uri = Uri.parse(data);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC Pro App"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// MODE TOGGLE
            SegmentedButton<NfcMode>(
              segments: const [
                ButtonSegment(
                  value: NfcMode.read,
                  label: Text("READ"),
                  icon: Icon(Icons.nfc),
                ),
                ButtonSegment(
                  value: NfcMode.write,
                  label: Text("WRITE"),
                  icon: Icon(Icons.edit),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (value) {
                setState(() => mode = value.first);
              },
            ),

            const SizedBox(height: 30),

            /// NFC ICON
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isScanning
                    ? Colors.indigo.withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
              child: Icon(
                Icons.nfc,
                size: 80,
                color: isScanning ? Colors.indigo : Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            /// STATUS
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            /// WRITE INPUT
            if (mode == NfcMode.write)
              TextField(
                controller: writeController,
                decoration: const InputDecoration(
                  labelText: "Text / URL / UPI link",
                  border: OutlineInputBorder(),
                ),
              ),

            const Spacer(),

            /// ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(
                  mode == NfcMode.read ? Icons.wifi_tethering : Icons.save,
                ),
                label: Text(
                  mode == NfcMode.read ? "Scan NFC" : "Write NFC",
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: isScanning ? null : startNfc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
