import 'package:flutter/material.dart';
import 'package:couplegoals/widgets/currency_converter_widget.dart';
import 'package:couplegoals/widgets/time_converter_widget.dart';
import 'package:couplegoals/widgets/gold_price_widget.dart'; // <-- IMPORT BARU

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alat Bantu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // Widget 1: Harga Emas (Kita taruh paling atas karena menarik)
          GoldPriceWidget(),
          SizedBox(height: 16),

          // Widget 2: Konverter Mata Uang
          CurrencyConverterWidget(),
          SizedBox(height: 16),

          // Widget 3: Waktu Dunia
          TimeConverterWidget(),
        ],
      ),
    );
  }
}
