import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../core/currency_utils.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  
  String _selectedCategory = 'Yemek';
  String _selectedType = 'expense';
  bool _isLoading = false;

  final TransactionService _transactionService = TransactionService();

  final List<String> _categories = ['Yemek', 'Eğlence', 'Ulaşım', 'Market', 'Fatura', 'Maaş', 'Diğer'];

  // Dynamic Colors
  Color get darkNavy => Theme.of(context).cardColor;
  Color get backgroundNavy => Theme.of(context).scaffoldBackgroundColor;
  Color get primaryGreen => Theme.of(context).primaryColor;
  Color get coralRed => Theme.of(context).colorScheme.error;
  Color get lightText => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get subText => Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54;

  Future<void> _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
        final rate = currencyProvider.currentRate;
        
        String cleanAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
        final enteredAmount = double.parse(cleanAmount) / 100;
        
        // Girilen miktar gösterilen kurda (örn USD), veritabanına her zaman TRY (ana kur) olarak kaydedilmeli.
        // TRY = enteredAmount / rate
        final tryAmount = enteredAmount / rate;

        final tx = Transaction(
          id: '', // Will be assigned by backend
          amount: tryAmount,
          category: _selectedCategory,
          type: _selectedType,
          date: DateTime.now(),
        );

        await _transactionService.addTransaction(tx);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harcama başarıyla eklendi')),
          );
          Navigator.pop(context, true); // Return true to refresh list
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundNavy,
      appBar: AppBar(
        title: Text(
          'Yeni İşlem Ekle',
          style: GoogleFonts.outfit(
            color: lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundNavy,
        elevation: 0,
        iconTheme: IconThemeData(color: lightText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // İşlem Türü Seçimi (Gelir / Gider)
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton('Gelir', 'income', primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeButton('Gider', 'expense', coralRed),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Miktar
              Consumer<CurrencyProvider>(
                builder: (context, currencyProvider, child) {
                  return TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [CurrencyInputFormatter()],
                    style: GoogleFonts.inter(color: lightText, fontSize: 18),
                    decoration: _inputDecoration('Miktar (${currencyProvider.selectedCurrency})', Icons.attach_money),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir miktar girin';
                      }
                      String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (clean.isEmpty || double.parse(clean) <= 0) {
                        return 'Geçerli bir sayı girin';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Kategori Seçimi
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: darkNavy,
                style: GoogleFonts.inter(color: lightText, fontSize: 16),
                decoration: _inputDecoration('Kategori', Icons.category),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 48),

              // Kaydet Butonu
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Kaydet',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, String type, Color activeColor) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // Otomatik kategori ayarı
          if (type == 'income') {
            _selectedCategory = 'Maaş';
          } else if (type == 'expense' && _selectedCategory == 'Maaş') {
            _selectedCategory = 'Yemek';
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : darkNavy,
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isSelected ? activeColor : subText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: subText),
      prefixIcon: Icon(icon, color: subText),
      filled: true,
      fillColor: darkNavy,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: coralRed, width: 2),
      ),
    );
  }
}
