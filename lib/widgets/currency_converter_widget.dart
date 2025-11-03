import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:couplegoals/services/api_service.dart';
import 'package:couplegoals/utils/formatters.dart';
import 'package:intl/intl.dart';

class CurrencyConverterWidget extends StatefulWidget {
  const CurrencyConverterWidget({super.key});

  @override
  State<CurrencyConverterWidget> createState() =>
      _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  final ApiService _apiService = ApiService();
  final _amountController = TextEditingController();

  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'JPY', 'SGD'];
  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';

  String _resultText = 'Hasil akan muncul di sini';
  bool _isLoading = false;

  void _convertCurrency() async {
    if (_amountController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _resultText = 'Menghitung...';
    });

    try {
      final double amount = double.parse(_amountController.text);
      final ratesData = await _apiService.getExchangeRates(_fromCurrency);

      if (ratesData['result'] == 'success') {
        final Map<String, dynamic> rates = ratesData['conversion_rates'];
        // API exchangerate-api.com mengembalikan rate relatif ke base_code
        // Jadi, kita hanya perlu mengambil rate untuk mata uang tujuan
        final double rate = (rates[_toCurrency] ?? 1.0).toDouble();
        final double result = amount * rate;

        // Format hasil
        final formattedAmount = Formatters.formatCurrency(amount);

        // INI YANG ERROR: Sekarang 'NumberFormat' sudah dikenali
        final formattedResult = NumberFormat.currency(
          // Kita set 'en_US' agar simbolnya mengikuti kode
          // (Jika pakai 'id_ID', simbolnya akan selalu 'Rp')
          locale: 'en_US',
          symbol: '$_toCurrency ', // Simbol dinamis
          decimalDigits: 2,
        ).format(result);

        setState(() {
          _resultText = '$formattedAmount $_fromCurrency = $formattedResult';
        });
      } else {
        throw Exception('API result failed');
      }
    } catch (e) {
      setState(() {
        _resultText = 'Error: Gagal menghitung.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konverter Mata Uang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCurrencyDropdown(true),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.swap_horiz, color: Colors.teal),
                ),
                _buildCurrencyDropdown(false),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _convertCurrency,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text('Konversi'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _resultText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(bool isFrom) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: isFrom ? _fromCurrency : _toCurrency,
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            if (isFrom) {
              _fromCurrency = value;
            } else {
              _toCurrency = value;
            }
          });
        },
        items: _currencies
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
