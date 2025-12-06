import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldApiService {
  // GANTI DENGAN API KEY DARI GOLDAPI.IO ANDA
  static const String _apiKey = 'goldapi-jxjzsmihnau1u-io';

  static const String _baseUrl =
      ' https://www.goldapi.io/api/:symbol/:currency/:date?';

  // Mengambil harga emas (XAU) dalam mata uang Rupiah (IDR)
  Future<Map<String, dynamic>> getGoldPrice() async {
    // Format URL: /XAU/IDR (Harga 1 Ounce Emas dalam Rupiah)
    final url = Uri.parse('$_baseUrl/XAU/IDR');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-access-token': _apiKey, // Autentikasi header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat harga emas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi Gold API: $e');
    }
  }
}
