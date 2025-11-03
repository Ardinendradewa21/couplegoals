import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeConverterWidget extends StatefulWidget {
  const TimeConverterWidget({super.key});

  @override
  State<TimeConverterWidget> createState() => _TimeConverterWidgetState();
}

class _TimeConverterWidgetState extends State<TimeConverterWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Update jam setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Hentikan timer saat widget dihapus
    super.dispose();
  }

  // Helper untuk format jam
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  // Helper untuk format tanggal
  String _formatDate(DateTime time) {
    return DateFormat('dd MMM yyyy').format(time);
  }

  @override
  Widget build(BuildContext context) {
    // Ambil UTC sebagai basis
    final utcTime = _currentTime.toUtc();

    // (Sesuai permintaan Anda: WIB, WITA, WIT, London)
    final wibTime = utcTime.add(const Duration(hours: 7)); // UTC+7
    final witaTime = utcTime.add(const Duration(hours: 8)); // UTC+8
    final witTime = utcTime.add(const Duration(hours: 9)); // UTC+9
    final londonTime = utcTime.add(
      const Duration(hours: 1),
    ); // UTC+1 (BST/London)

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Waktu Pasar Global', // (Sesuai tema finansial)
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimeRow(
              'WIB (Jakarta)',
              wibTime,
              Icons.location_city,
              Colors.blue,
            ),
            _buildTimeRow(
              'WITA (Bali)',
              witaTime,
              Icons.surfing,
              Colors.orange,
            ),
            _buildTimeRow(
              'WIT (Jayapura)',
              witTime,
              Icons.landscape,
              Colors.green,
            ),
            _buildTimeRow(
              'GMT+1 (London)',
              londonTime,
              Icons.account_balance, // (Icon bank/pasar modal)
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String zone, DateTime time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              zone,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(time),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(time),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
