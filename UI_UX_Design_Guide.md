# ParaPulse UI/UX Tasarım Rehberi

Bu belge, ParaPulse (Kişisel Finans ve Harcama Takip Uygulaması) projesinin 2. haftasındaki UI/UX tasarım temelini oluşturmak için hazırlanmıştır. Hedefimiz modern, temiz (clean UI), güven veren ve kullanımı kolay bir arayüz tasarlamaktır.

## 1. Renk Paleti (Color Palette)

Bir finans uygulaması olduğu için "güven, netlik ve hız" uyandıran renkler seçilmiştir. 

| Renk Rolü | Renk Adı | HEX Kodu | Kullanım Alanı |
| :--- | :--- | :--- | :--- |
| **Ana Renk (Primary)** | Gece Mavisi | `#0A2540` | Üst menü barı, ana butonlar, marka kimliği logoları. (Güven ve profesyonellik hissi verir). |
| **İkincil Renk (Secondary)**| Bulut Grisi | `#F3F4F6` | Uygulama arka planı, kart alt planları. (Okunabilirliği ve kartların kontrastını artırır). |
| **Gelir / Başarı Vurgusu** | Zümrüt Yeşili| `#10B981` | Gelir rakamları, başarı mesajları, artış okları. |
| **Gider / Uyarı Vurgusu** | Mercan Kırmızısı| `#FF6B6B` | Gider rakamları, silme butonları, hata mesajları. |
| **Yazı Rengi (Text Dark)** | Koyu Arduvaz | `#1E293B` | Ana başlıklar, normal okuma metinleri. |
| **Yazı Rengi (Text Light)**| Gümüş Grisi | `#94A3B8` | Alt başlıklar, pasif ikonlar, placeholder metinleri. |

---

## 2. Tipografi (Typography)

Modern ve minimal bir görünüm elde etmek için okunabilirliği yüksek, dijital ekranlara tam uyumlu fontlar seçilmiştir.

* **Ana Font (Başlıklar ve Rakamlar): [Poppins](https://fonts.google.com/specimen/Poppins)**
  * Sans-serif geometrik yapısıyla, bakiye (örn: `₺12,500`) ve ana ekran başlıklarında oldukça şık ve net durur.
  * **Kullanım:** Bakiye gösterimi (Bold), Sayfa Başlıkları (Semi-bold).
* **İkincil Font (Metinler ve Detaylar): [Inter](https://fonts.google.com/specimen/Inter)**
  * Ekrandaki işlem satırları, tarih bilgileri ve uzun yazılarda yüksek okunabilirlik sağlar.
  * **Kullanım:** Harcama listesi açıklamaları, buton metinleri, form labelları.

---

## 3. Wireframe Planı (Ekran Senaryoları)

Aşağıda temel ekranların kaba taslak (wireframe) hiyerarşisi çıkartılmıştır:

### Ekran 1: Giriş / Kayıt Ekranı (Login Screen)
* **Header:** ParaPulse Logosu ve Uygulama Sloganı (Örn: "Finansal ritmini yakala").
* **Form Alanı:** 
  * E-posta Giriş Alanı (İkonlu: ✉️)
  * Şifre Giriş Alanı (İkonlu: 🔒, Gizle/Göster butonu)
  * "Şifremi Unuttum" linki (Hafif gri).
* **Aksiyon:** 
  * Büyük "Giriş Yap" Butonu (Ana Renk - `#0A2540`).
* **Footer:** "Hesabın yok mu? **Kayıt Ol**" yönlendirme metni.

### Ekran 2: Ana Dashboard (Home)
* **Top Bar (Üst Kısım):** 
  * Karşılama mesajı: "Merhaba, Efe 👋"
  * Sağ üst köşede bildirim çanı veya profil fotoğrafı.
* **Bakiye Kartı (Hero Section):** 
  * Geniş, köşeleri yuvarlatılmış (border-radius: 16px) bir kart. Arka planı Ana Renk (`#0A2540`).
  * "Toplam Bakiyeniz" yazısı ve büyük puntolu net rakam (Örn: `₺15,450.00`).
  * Kartın altında yan yana iki alan: 
    * **[↓ Gelirler]:** Yeşil (`#10B981`) renkte toplam gelir.
    * **[↑ Giderler]:** Kırmızı (`#FF6B6B`) renkte toplam gider.
* **Hızlı İşlem Butonu:** Alt ortaya sabitlenmiş büyücek bir **+** butonu (Floating Action Button).
* **Harcama Listesi (Recent Transactions):**
  * Başlık: "Son İşlemler" & "Tümünü Gör" butonu. 
  * İkon, İşlem Başlığı (Kategori), Tarih (Örn: Kahve, 12 Ekim) sola dayalı.
  * Miktar sağa dayalı (-₺80 formatında kırmızı / +₺500 formatında yeşil).

### Ekran 3: Harcama/Gelir Ekleme Ekranı (Add Transaction)
* **Header:** Kapatma butonu "X" ve Başlık: "Yeni İşlem Ekle".
* **Tür Seçimi (Segmented Control):** 
  * Yan yana iki tuş (Toggle): `[ Gider | Gelir ]`. Seçili olan Canlı bir renkle vurgulanacak.
* **Tutar Girişi:** Büyük fontlu numaratör alanı (Örn: Klavye üzerinden `₺ 0`).
* **Form Detayları:**
  * **Kategori Seçici:** Bir dropdown veya yatay scroll ikon listesi (Market, Fatura, Eğitim, Maaş).
  * **Açıklama (Opsiyonel):** Basit bir metin input kutusu.
  * **Tarih Seçici:** Varsayılan "Bugün" (Tıklanabilir takvim).
* **Aksiyon:** Ekranın alt kısmına sabitlenmiş, boydan boya geniş "Kaydet" butonu.

---
> **Not:** Tasarımı kodlarken bu renk Hex kodlarını CSS/SCSS (veya Tailwind kullanıyorsanız config dosyasına) değişken olarak ekleyerek geliştirme sürecinde ciddi hız kazanabilirsiniz.
