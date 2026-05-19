import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _codeSent = false; // İkinci aşama için flag
  bool _obscurePassword = true;

  // Dynamic Colors
  Color get darkNavy => Theme.of(context).cardColor;
  Color get backgroundNavy => Theme.of(context).scaffoldBackgroundColor;
  Color get primaryGreen => Theme.of(context).primaryColor;
  Color get coralRed => Theme.of(context).colorScheme.error;
  Color get lightText =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get subText =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // --- AŞAMA 1: Kodu Gönder ---
  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.sendResetCode(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('6 haneli doğrulama kodu e-postanıza gönderildi'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: coralRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- AŞAMA 2: Şifreyi Sıfırla ---
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _newPasswordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Şifreniz başarıyla güncellendi! Lütfen giriş yapın.'),
          backgroundColor: primaryGreen,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: coralRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: subText),
      prefixIcon: Icon(icon, color: subText),
      suffixIcon: suffixIcon,
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: coralRed, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundNavy,
      appBar: AppBar(
        title: Text(
          'Şifremi Unuttum',
          style: GoogleFonts.outfit(color: lightText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundNavy,
        elevation: 0,
        iconTheme: IconThemeData(color: lightText),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _codeSent ? _buildResetStep() : _buildEmailStep(),
            ),
          ),
        ),
      ),
    );
  }

  // --- AŞAMA 1 UI: E-posta ---
  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_unread_outlined, size: 80, color: primaryGreen),
        const SizedBox(height: 24),
        Text(
          'Şifre Sıfırlama',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: lightText,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Kayıtlı e-posta adresinize 6 haneli bir doğrulama kodu göndereceğiz.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: subText, fontSize: 15),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: lightText, fontSize: 16),
          decoration: _inputDecoration('E-posta adresi', Icons.email_outlined),
          validator: (v) {
            if (v == null || v.isEmpty) return 'E-posta adresi gerekli';
            if (!v.contains('@')) return 'Geçerli bir e-posta girin';
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryGreen))
              : ElevatedButton.icon(
                  onPressed: _sendCode,
                  icon: const Icon(Icons.send_outlined, color: Colors.white),
                  label: Text(
                    'Kodu Gönder',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                ),
        ),
      ],
    );
  }

  // --- AŞAMA 2 UI: Kod + Yeni Şifre ---
  Widget _buildResetStep() {
    return Column(
      key: const ValueKey('reset_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.lock_reset_outlined, size: 80, color: primaryGreen),
        const SizedBox(height: 24),
        Text(
          'Yeni Şifre Belirle',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: lightText,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(color: subText, fontSize: 15),
            children: [
              const TextSpan(text: 'Kodu '),
              TextSpan(
                text: _emailController.text.trim(),
                style: GoogleFonts.inter(
                    color: primaryGreen, fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' adresine gönderdik.'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 6 Haneli Kod
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: GoogleFonts.inter(
              color: lightText, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: _inputDecoration('Doğrulama Kodu', Icons.pin_outlined),
          validator: (v) {
            if (v == null || v.length != 6) return '6 haneli kodu eksiksiz girin';
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Yeni Şifre
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.inter(color: lightText, fontSize: 16),
          decoration: _inputDecoration(
            'Yeni Şifre',
            Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: subText,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.length < 6) return 'Şifre en az 6 karakter olmalı';
            return null;
          },
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: 56,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryGreen))
              : ElevatedButton.icon(
                  onPressed: _resetPassword,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    'Şifremi Güncelle',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Geri dön - Farklı e-posta
        TextButton.icon(
          onPressed: () => setState(() {
            _codeSent = false;
            _codeController.clear();
            _newPasswordController.clear();
          }),
          icon: Icon(Icons.arrow_back, color: subText, size: 18),
          label: Text(
            'Farklı e-posta kullan',
            style: GoogleFonts.inter(color: subText),
          ),
        ),
      ],
    );
  }
}
