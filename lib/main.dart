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
      home: NfcScreen(),
    );
  }
}

class NfcScreen extends StatefulWidget {
  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  String result = "No NFC action yet";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter NFC Demo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(result, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                NfcService.readTag(
                  onData: (data) {
                    setState(() => result = "Read: $data");
                  },
                  onError: (err) {
                    setState(() => result = err);
                  },
                );
              },
              child: const Text("Read NFC"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                NfcService.writeTag(
                  text: "Hello NFC from Flutter",
                  onSuccess: (msg) {
                    setState(() => result = msg);
                  },
                  onError: (err) {
                    setState(() => result = err);
                  },
                );
              },
              child: const Text("Write NFC"),
            ),
          ],
        ),
      ),
    );
  }
}
