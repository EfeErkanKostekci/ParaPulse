# ParaPulse - Yapay Zeka Destekli Kişisel Finans Koçu
ParaPulse, kullanıcıların gelir ve giderlerini takip etmelerini sağlayan, modern teknolojilerle donatılmış bir finansal yönetim uygulamasıdır. 🛠️ Kullanılan TeknolojilerProje, "probleme uygun teknoloji seçimi" prensibiyle geliştirilmiştir: 
#Frontend: Flutter (Cross-platform mobil geliştirme) 
#Backend: Node.js & Express.js Veritabanı: MongoDB (NoSQL & Bulut tabanlı) 
#Güvenlik: JWT (JSON Web Token) & Bcryptjs 

## Proje Durumu (10 Haftalık Plan)
✅1. Hafta: Altyapı kurulumu ve veritabanı bağlantısı.
✅2. Hafta: Kullanıcı kayıt/giriş sistemi (Auth) ve JWT entegrasyonu.
✅3. Hafta: Harcama (Transaction) yönetimi ve CRUD işlemleri.
⏳ (Sıradaki) Kurulum ve Çalıştırma

## Backend Kurulumu
backend klasörüne gidin: cd backend
Gerekli paketleri yükleyin: npm install
.env dosyasını oluşturun ve değişkenleri tanımlayın:
  Kod snippet'iPORT=5000
  MONGO_URI=mongodb://127.0.0.1:27017/parapulse
  JWT_SECRET=senin_gizli_anahtarin
Sunucuyu başlatın: Bashnode server.js

## Güvenlik Özellikleri
Kullanıcı şifreleri veritabanında asla açık metin olarak saklanmaz; 
Bcrypt ile hash'lenir. API uç noktaları JWT ile korunmaktadır, sadece yetkili kullanıcılar işlem yapabilir. 
