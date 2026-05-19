const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

// Çevresel değişkenleri yükle
dotenv.config();

// Veritabanına bağlan
connectDB();

const app = express();

// Middleware
app.use(cors()); // CORS'u aktif et
app.use(express.json()); // JSON okumayı aktif et

// Temel route
app.get('/', (req, res) => {
  res.send('ParaPulse API çalışıyor...');
});

// İleride eklenecek route'lar
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/transactions', require('./routes/transactionRoutes'));

// 404 - Bilinmeyen rota (HTML yerine JSON döndür)
app.use((req, res) => {
  res.status(404).json({ message: `Rota bulunamadı: ${req.method} ${req.originalUrl}` });
});

// Global hata yöneticisi (HTML yerine JSON döndür)
app.use((err, req, res, next) => { // eslint-disable-line no-unused-vars
  console.error(err.stack);
  res.status(err.status || 500).json({ message: err.message || 'Sunucu hatası' });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Sunucu ${PORT} portunda başlatıldı`);
});
