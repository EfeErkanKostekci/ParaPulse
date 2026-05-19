import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class CurrencyUtils {
  static String formatAmount(double amount, {String currency = 'TRY', double rate = 1.0}) {
    final convertedAmount = amount * rate;
    
    String symbol = 'TL';
    if (currency == 'USD') symbol = '\$';
    else if (currency == 'EUR') symbol = '€';

    final format = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '',
      decimalDigits: 2,
    );
    
    // TRY -> 1.000,00 TL
    // USD -> $ 1.000,00
    // EUR -> € 1.000,00
    if (currency == 'TRY') {
      return '${format.format(convertedAmount).trim()} TL';
    } else {
      return '$symbol ${format.format(convertedAmount).trim()}';
    }
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only allow digits
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.parse(numericOnly) / 100;
    final format = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '',
      decimalDigits: 2,
    );
    
    String newText = format.format(value).trim();

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
