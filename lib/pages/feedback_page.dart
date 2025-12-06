import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();

  void _submitFeedback() {
    if (_feedbackController.text.isEmpty) {
      // Tampilkan notifikasi jika kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saran dan kesan tidak boleh kosong.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulasi pengiriman
    print('Saran & Kesan: ${_feedbackController.text}');

    // Tampilkan notifikasi sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terima kasih atas saran & kesannya!'),
        backgroundColor: Colors.green,
      ),
    );

    // Kosongkan field dan kembali
    _feedbackController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran & Kesan'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Saran & Kesan Mata Kuliah\nPemrograman Aplikasi Mobile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _feedbackController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Tuliskan saran dan kesan Anda di sini...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              labelText: 'Saran & Kesan',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitFeedback,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Kirim', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
