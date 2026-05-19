import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest/TRY';

  Future<Map<String, double>> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        return {
          'TRY': 1.0,
          'USD': (rates['USD'] as num).toDouble(),
          'EUR': (rates['EUR'] as num).toDouble(),
        };
      } else {
        throw Exception('Failed to fetch rates');
      }
    } catch (e) {
      // Çevrimdışı olma veya hata durumunda yaklaşık fallback kurları
      return {
        'TRY': 1.0,
        'USD': 0.031,
        'EUR': 0.028,
      };
    }
  }
}
