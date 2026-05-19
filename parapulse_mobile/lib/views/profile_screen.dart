import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/theme_provider.dart';
import '../providers/currency_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _userName = '';
  String _userEmail = '';

  // Dynamic Colors
  Color get darkNavy => Theme.of(context).cardColor;
  Color get backgroundNavy => Theme.of(context).scaffoldBackgroundColor;
  Color get primaryGreen => Theme.of(context).primaryColor;
  Color get coralRed => Theme.of(context).colorScheme.error;
  Color get lightText => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get subText => Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Kullanıcı Adı';
      _userEmail = prefs.getString('user_email') ?? 'Kullanıcı E-posta';
    });
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundNavy,
      appBar: AppBar(
        title: Text(
          'Profil ve Ayarlar',
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
        child: Column(
          children: [
            // Profil Kartı
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: darkNavy,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryGreen.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: GoogleFonts.outfit(
                            color: lightText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail,
                          style: GoogleFonts.inter(
                            color: subText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Ayarlar Listesi
            _buildThemeToggle(),
            const SizedBox(height: 16),
            _buildColorPicker(),
            const SizedBox(height: 16),
            _buildCurrencyDropdown(),
            const SizedBox(height: 16),
            _buildListTile(
              icon: Icons.notifications_active,
              title: 'Bildirim Ayarları',
              onTap: () {},
            ),
            const SizedBox(height: 48),

            // Çıkış Yap Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Çıkış Yap',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coralRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tileColor: darkNavy,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryGreen),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: lightText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: subText, size: 16),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Container(
          decoration: BoxDecoration(
            color: darkNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            title: Text(
              'Koyu Tema',
              style: GoogleFonts.inter(
                color: lightText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeNotifier.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeNotifier.accentColor,
              ),
            ),
            value: themeNotifier.isDarkMode,
            activeColor: themeNotifier.accentColor,
            onChanged: (value) {
              themeNotifier.toggleTheme(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildColorPicker() {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: darkNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vurgu Rengi',
                style: GoogleFonts.inter(
                  color: lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  _colorCircle(themeNotifier, ThemeNotifier.greenAccent),
                  const SizedBox(width: 8),
                  _colorCircle(themeNotifier, ThemeNotifier.blueAccent),
                  const SizedBox(width: 8),
                  _colorCircle(themeNotifier, ThemeNotifier.purpleAccent),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorCircle(ThemeNotifier notifier, Color color) {
    final isSelected = notifier.accentColor == color;
    return GestureDetector(
      onTap: () => notifier.setAccentColor(color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? lightText : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: darkNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.currency_exchange, color: primaryGreen),
                  const SizedBox(width: 16),
                  Text(
                    'Para Birimi',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: currencyProvider.selectedCurrency,
                dropdownColor: darkNavy,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: primaryGreen),
                style: GoogleFonts.inter(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                items: ['TRY', 'USD', 'EUR'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    currencyProvider.setCurrency(newValue);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
