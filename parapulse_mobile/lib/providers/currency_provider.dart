import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedCurrency = 'TRY';
  Map<String, double> _rates = {'TRY': 1.0, 'USD': 1.0, 'EUR': 1.0};
  bool _isLoading = false;

  String get selectedCurrency => _selectedCurrency;
  Map<String, double> get rates => _rates;
  bool get isLoading => _isLoading;

  double get currentRate => _rates[_selectedCurrency] ?? 1.0;

  final CurrencyService _currencyService = CurrencyService();

  CurrencyProvider() {
    _loadPreferencesAndRates();
  }

  Future<void> _loadPreferencesAndRates() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('selectedCurrency') ?? 'TRY';

    try {
      _rates = await _currencyService.fetchRates();
    } catch (e) {
      // Hata durumunda servis fallback kurları döndürür
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrency(String currencyCode) async {
    if (['TRY', 'USD', 'EUR'].contains(currencyCode)) {
      _selectedCurrency = currencyCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCurrency', _selectedCurrency);
      notifyListeners();
    }
  }
}
