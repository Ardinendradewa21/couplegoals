import 'package:flutter/material.dart';
import 'package:couplegoals/services/gold_api_service.dart';
import 'package:intl/intl.dart';

class GoldPriceWidget extends StatefulWidget {
  const GoldPriceWidget({super.key});

  @override
  State<GoldPriceWidget> createState() => _GoldPriceWidgetState();
}

class _GoldPriceWidgetState extends State<GoldPriceWidget> {
  final GoldApiService _goldService = GoldApiService();

  // State untuk data
  double _pricePerGram = 0.0;
  double _pricePerOunce = 0.0;
  String _lastUpdated = '-';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGoldPrice();
  }

  void _fetchGoldPrice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _goldService.getGoldPrice();

      // Data dari API (harga per Ounce)
      final double priceOunce = (data['price'] as num).toDouble();

      // Konversi ke Gram (1 Troy Ounce = 31.1035 Gram)
      final double priceGram = priceOunce / 31.1035;

      // Ambil waktu update (timestamp) jika ada, atau pakai waktu sekarang
      final now = DateTime.now();
      final formattedTime = DateFormat(
        'dd MMM yyyy, HH:mm',
        'id_ID',
      ).format(now);

      setState(() {
        _pricePerOunce = priceOunce;
        _pricePerGram = priceGram;
        _lastUpdated = formattedTime;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil data. Cek koneksi/API Limit.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format mata uang
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Beri warna emas sedikit agar tematik
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Harga Emas (Logam Mulia)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.brown),
                  onPressed: _isLoading ? null : _fetchGoldPrice,
                  tooltip: 'Refresh Harga',
                ),
              ],
            ),
            const Divider(color: Colors.brown),
            const SizedBox(height: 10),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            else if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Column(
                children: [
                  _buildPriceRow(
                    'Harga per Gram',
                    currencyFormatter.format(_pricePerGram),
                    isMain: true,
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    'Harga per Ounce',
                    currencyFormatter.format(_pricePerOunce),
                    isMain: false,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Diperbarui: $_lastUpdated',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.brown.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {required bool isMain}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMain ? 16 : 14,
            color: Colors.brown.shade700,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: isMain ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isMain ? Colors.green.shade800 : Colors.brown.shade800,
          ),
        ),
      ],
    );
  }
}
