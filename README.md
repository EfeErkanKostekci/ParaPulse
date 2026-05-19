# 💸 ParaPulse - Akıllı Kişisel Finans ve Bütçe Takip Uygulaması

ParaPulse, kullanıcıların gelir ve giderlerini detaylı olarak takip edebildikleri, dinamik temalara ve canlı döviz kurlarına sahip, full-stack (Flutter + Node.js) bir finansal yönetim platformudur.

## 🚀 Öne Çıkan Özellikler

- **Gelişmiş Filtreleme ve Analiz:** Günlük, haftalık, aylık ve yıllık bazda harcama dökümleri. İnteraktif Bar ve Pasta grafikler (PieChart & BarChart).
- **Çoklu Para Birimi (Live Currency):** Harcamalar veritabanında ana para biriminde (TL) tutulurken, API üzerinden çekilen canlı kurlarla anlık olarak USD, EUR vb. birimlere dönüştürülüp görüntülenebilir.
- **Dinamik Tema Motoru:** Kullanıcı tercihine göre anında değişebilen Açık ve Koyu mod desteği. (Tüm grafik ve metin renkleri temaya duyarlıdır).
- **Güvenli Kimlik Doğrulama (Auth):** - JWT tabanlı giriş ve kayıt sistemi.
  - **Nodemailer** entegrasyonu ile 6 haneli OTP (Tek Kullanımlık Şifre) destekli şifre sıfırlama akışı (Şifremi Unuttum).
- **Kusursuz UI/UX:** '100.000,00 TL' formatında yerelleştirilmiş para gösterimi ve kronolojik (en yeni işlem en üstte) akıllı listeleme mantığı.

## 🛠️ Kullanılan Teknolojiler

### Mobil Geliştirme (Frontend)
- **Framework:** Flutter (Dart)
- **State Management:** Provider (Tema ve Para Birimi yönetimi için)
- **Görselleştirme:** fl_chart (Grafikler)
- **Diğer Paketler:** google_fonts, shared_preferences, http, intl

### Sunucu & Veritabanı (Backend)
- **Ortam:** Node.js, Express.js
- **Veritabanı:** MongoDB (Mongoose ORM)
- **Güvenlik & Auth:** bcrypt (Şifre hashleme), jsonwebtoken (JWT)
- **Mail Servisi:** Nodemailer (SMTP tabanlı OTP gönderimi)

---

## ⚙️ Kurulum ve Çalıştırma

Projeyi yerel bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

### 1. Backend (Node.js) Kurulumu
```bash
# Backend klasörüne gidin
cd backend

# Gerekli paketleri yükleyin
npm install

# .env dosyasını oluşturun ve aşağıdaki değişkenleri ekleyin:
# PORT=5000
# MONGO_URI=sizin_mongodb_baglanti_adresiniz
# JWT_SECRET=sizin_gizli_anahtariniz
# EMAIL_USER=sizin_gmail_adresiniz
# EMAIL_PASS=sizin_gmail_uygulama_sifreniz

# Sunucuyu başlatın
npm run dev
```

### 2. Mobil Uygulama Kurulumu
```bash
# Mobil klasörüne gidin
cd parapulse_mobile

# Flutter paketlerini indirin
flutter pub get

# Uygulamayı çalıştırın (Android Emülatör veya Fiziksel Cihaz)
flutter run
```
Not: Android emülatör kullanıyorsanız, auth_service.dart veya API servislerinizdeki base URL değerinin localhost yerine http://10.0.2.2:5000 olarak ayarlandığından emin olun.
