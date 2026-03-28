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
app.use('/api/users', require('./routes/authRoutes'));
app.use('/api/transactions', require('./routes/transactionRoutes'));

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Sunucu ${PORT} portunda başlatıldı`);
});
