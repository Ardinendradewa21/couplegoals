import 'dart:convert';
import 'package:http/http.dart'
    as http; // Pastikan http sudah ada di pubspec.yaml

class ApiService {
  // --- KODE API ASLI ---

  // V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V
  // GANTI 'YOUR_API_KEY_HERE' DENGAN API KEY ANDA YANG ASLI
  // V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V-- V
  static const String _apiKey = 'db6caf04586a2eea5bfc0a34';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    print('Memanggil API Service (REAL)...');

    final url = Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Jika server merespons OK (200), parse JSON.
        print('API call sukses.');
        return json.decode(response.body);
      } else {
        // Jika server tidak merespons OK.
        print('Gagal memuat kurs: ${response.statusCode}');
        throw Exception('Gagal memuat kurs mata uang: ${response.statusCode}');
      }
    } catch (e) {
      // Jika ada error koneksi (misal: tidak ada internet)
      print('Error koneksi API: $e');
      throw Exception('Error koneksi: $e');
    }

    /*
    // --- SIMULASI (DI-NONAKTIFKAN) ---
    await Future.delayed(const Duration(seconds: 1));
    final mockData = {
      "result": "success",
      "base_code": baseCurrency,
      "conversion_rates": {
        "IDR": 16250.75,
        "USD": 1.00,
        "EUR": 0.92,
        "JPY": 155.45,
        "SGD": 1.35
      }
    };
    mockData['conversion_rates']![baseCurrency] = 1.0;
    return mockData;
    */
  }
}
