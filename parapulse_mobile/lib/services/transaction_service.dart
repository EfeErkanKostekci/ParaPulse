import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/transactions';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Harcamalar getirilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Harcamalar getirilirken hata oluştu: $e');
    }
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Transaction.fromJson(data);
      } else {
        throw Exception('Harcama eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Harcama eklenirken hata oluştu: $e');
    }
  }
}
