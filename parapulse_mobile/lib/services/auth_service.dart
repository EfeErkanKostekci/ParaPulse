import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // IP Adresi Notu: Emülatörden localhost'taki backend'e bağlanırken:
  // - Android Emülatör için: "http://10.0.2.2:5000/api/users" (genellikle 10.0.2.2 kullanılır)
  // - iOS Simülatör için: "http://127.0.0.1:5000/api/users" veya "http://localhost:5000/api/users"
  // - Gerçek cihaz için: "http://192.168.X.X:5000/api/users" (Bilgisayarınızın ağ üzerindeki yerel IP'si)
  //
  // Backend'de "/api/users/login" ve "/api/users/register" varsa baseUrl buna uygun olmalıdır.
  static const String baseUrl = 'http://10.0.2.2:5000/api/users';

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);

        // Token'ı SharedPreferences ile telefonun hafızasına kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', user.token);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_email', user.email);

        return user;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Giriş Başarısız!');
      }
    } catch (e) {
      throw Exception('Giriş hatası: $e');
    }
  }

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);

        // Token'ı kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', user.token);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_email', user.email);

        return user;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Kayıt Başarısız!');
      }
    } catch (e) {
      throw Exception('Kayıt hatası: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  /// Gelen HTTP yanıtını güvenle JSON olarak parse eder.
  /// Backend HTML hata sayfası döndürürse anlamlı hata fırlatır.
  Map<String, dynamic> _safeJsonDecode(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      // HTML veya beklenmedik bir yanıt geldi
      throw Exception(
        'Sunucudan geçersiz yanıt alındı (HTTP ${response.statusCode}). '
        'Backend başlatıldığından ve /api/users rotalarının doğru çalıştığından emin olun.',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// 1. Adım: Kullanıcıya 6 haneli OTP kodu gönderir.
  Future<void> sendResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final body = _safeJsonDecode(response);
      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Kod gönderilemedi');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Bağlantı hatası: Sunucuya ulaşılamıyor. Backend’in çalıştığını kontrol edin.');
    }
  }

  /// 2. Adım: OTP kodunu ve yeni şifreyi backend’e gönderir.
  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code, 'newPassword': newPassword}),
      );
      final body = _safeJsonDecode(response);
      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Şifre sıfırlama başarısız');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Bağlantı hatası: Sunucuya ulaşılamıyor. Backend’in çalıştığını kontrol edin.');
    }
  }
}
