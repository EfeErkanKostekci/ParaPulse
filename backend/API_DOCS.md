# ParaPulse API Dokümantasyonu (V1)

## 1. Authentication (Kimlik Doğrulama) Uç Noktaları

### Kullanıcı Kaydı (Register)
- **URL:** `/api/v1/auth/register`
- **Method:** `POST`
- **Açıklama:** Yeni bir sistem kullanıcısı oluşturur. JWT token döner.

**Örnek İstek (Request):**
```json
{
  "name": "Efe Erkan",
  "email": "efe.erkan@example.com",
  "password": "password123"
}
```

**Örnek Yanıt (Response) - 201 Created:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "60d0fe4f5311236168a109ca",
    "name": "Efe Erkan",
    "email": "efe.erkan@example.com"
  }
}
```

### Kullanıcı Girişi (Login)
- **URL:** `/api/v1/auth/login`
- **Method:** `POST`
- **Açıklama:** Mevcut kullanıcının giriş yapmasını sağlar ve JWT döner.

**Örnek İstek (Request):**
```json
{
  "email": "efe.erkan@example.com",
  "password": "password123"
}
```

**Örnek Yanıt (Response) - 200 OK:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 2. Transactions (Finansal İşlemler) Uç Noktaları
*Not: Bu uç noktalar için `Authorization: Bearer <token>` başlığı (header) gereklidir.*

### İşlem Ekleme (Create Transaction)
- **URL:** `/api/v1/transactions`
- **Method:** `POST`
- **Açıklama:** Yeni bir gelir (income) veya gider (expense) işlemi ekler.

**Örnek İstek (Request):**
```json
{
  "amount": 250.50,
  "type": "expense",
  "category": "Market",
  "description": "Migros haftalık mutfak alışverişi",
  "date": "2023-10-15T14:30:00.000Z"
}
```

**Örnek Yanıt (Response) - 201 Created:**
```json
{
  "success": true,
  "data": {
    "_id": "60d0ff2f5311236168a109cc",
    "user": "60d0fe4f5311236168a109ca",
    "amount": 250.50,
    "type": "expense",
    "category": "Market",
    "description": "Migros haftalık mutfak alışverişi",
    "date": "2023-10-15T14:30:00.000Z",
    "createdAt": "2023-10-15T14:35:00.000Z"
  }
}
```

### İşlemleri Getirme (Get All Transactions)
- **URL:** `/api/v1/transactions`
- **Method:** `GET`
- **Açıklama:** Kullanıcıya ait olan geçmiş işlemleri getirir. (Gelecekte pagination, filtreleme - tarih, kategori vs. eklenebilir).

**Örnek İstek (Request Parametreleri Opsiyonel):**
`GET /api/v1/transactions?type=expense`

**Örnek Yanıt (Response) - 200 OK:**
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "_id": "60d0ff2f5311236168a109cc",
      "amount": 250.50,
      "type": "expense",
      "category": "Market",
      "date": "2023-10-15T14:30:00.000Z"
    }
  ]
}
```

### İşlem Güncelleme (Update Transaction)
- **URL:** `/api/v1/transactions/:id`
- **Method:** `PUT`
- **Açıklama:** Belirtilen ID'ye sahip işlemi günceller.

**Örnek İstek (Request):**
```json
{
  "amount": 280.00
}
```

**Örnek Yanıt (Response) - 200 OK:**
```json
{
  "success": true,
  "data": {
    "_id": "60d0ff2f5311236168a109cc",
    "amount": 280.00,
    "type": "expense",
    "category": "Market",
    "date": "2023-10-15T14:30:00.000Z"
  }
}
```

### İşlem Silme (Delete Transaction)
- **URL:** `/api/v1/transactions/:id`
- **Method:** `DELETE`
- **Açıklama:** Belirtilen ID'ye sahip işlemi kaldırır.

**Örnek Yanıt (Response) - 200 OK:**
```json
{
  "success": true,
  "data": {}
}
```
