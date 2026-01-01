import 'package:flutter/material.dart';
import 'nfc_service.dart';

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
      home: const NfcScreen(),
    );
  }
}

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  String result = "Tap a button to read or write NFC";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC Manager"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// NFC ICON CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.nfc,
                      size: 70,
                      color: Colors.indigo,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Hold your phone near the NFC tag",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// RESULT / STATUS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            /// READ BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.wifi_tethering),
                label: const Text(
                  "Read NFC",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  NfcService.readTag(
                    onData: (data) {
                      setState(() => result = "✅ Read Success:\n$data");
                    },
                    onError: (err) {
                      setState(() => result = "❌ Error:\n$err");
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            /// WRITE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Write NFC",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  NfcService.writeTag(
                    text: "Hello NFC from Flutter",
                    onSuccess: (msg) {
                      setState(() => result = "✅ $msg");
                    },
                    onError: (err) {
                      setState(() => result = "❌ Error:\n$err");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
