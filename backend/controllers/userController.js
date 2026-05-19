const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');

// --- Nodemailer Transporter Kurulumu ---
// .env dosyasındaki SMTP ayarlarını kullanır.
// Not: Gmail için Google hesabınızda 2 aşamalı doğrulama açık olmalı,
// ardından "Uygulama Şifresi" oluşturulmalıdır.
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT),
  secure: process.env.SMTP_SECURE === 'true',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// JWT Token Oluşturma Fonksiyonu
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

// @desc    Yeni kullanıcı kaydı
// @route   POST /api/users/register
// @access  Public
const registerUser = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Lütfen tüm alanları doldurun' });
    }

    // Kullanıcı var mı kontrol et
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({ message: 'Bu e-posta adresi zaten kullanılıyor' });
    }

    // Şifreyi hashle
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Kullanıcı oluştur
    const user = await User.create({
      name,
      email,
      password: hashedPassword,
    });

    if (user) {
      res.status(201).json({
        _id: user.id,
        name: user.name,
        email: user.email,
        token: generateToken(user._id),
      });
    } else {
      res.status(400).json({ message: 'Geçersiz kullanıcı verisi' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// @desc    Kullanıcı girişi & token al
// @route   POST /api/users/login
// @access  Public
const authUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Kullanıcı eşleşmesini bul
    const user = await User.findOne({ email });

    // Kullanıcı var mı & şifre doğru mu
    if (user && (await bcrypt.compare(password, user.password))) {
      res.json({
        _id: user.id,
        name: user.name,
        email: user.email,
        token: generateToken(user._id),
      });
    } else {
      res.status(401).json({ message: 'Geçersiz e-posta veya şifre' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// @desc    Şifremi unuttum - OTP kodu gönder
// @route   POST /api/users/forgot-password
// @access  Public
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Lütfen e-posta adresinizi girin' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'Bu e-posta adresine kayıtlı kullanıcı bulunamadı' });
    }

    // 6 haneli rastgele OTP kodu üret
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    // 15 dakika geçerlilik süresi
    const resetCodeExpiry = new Date(Date.now() + 15 * 60 * 1000);

    // Kodu veritabanına kaydet
    user.resetCode = resetCode;
    user.resetCodeExpiry = resetCodeExpiry;
    await user.save();

    // E-posta gönder
    await transporter.sendMail({
      from: process.env.SMTP_FROM,
      to: user.email,
      subject: 'ParaPulse - Şifre Sıfırlama Kodu',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; background: #f8fafc; border-radius: 12px;">
          <h2 style="color: #1e3a5f;">ParaPulse Şifre Sıfırlama</h2>
          <p style="color: #475569;">Merhaba <strong>${user.name}</strong>,</p>
          <p style="color: #475569;">Aşağıdaki 6 haneli kodu kullanarak şifrenizi sıfırlayabilirsiniz. Bu kod <strong>15 dakika</strong> geçerlidir.</p>
          <div style="text-align: center; margin: 32px 0;">
            <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #16a34a; background: #f0fdf4; padding: 16px 24px; border-radius: 8px;">${resetCode}</span>
          </div>
          <p style="color: #94a3b8; font-size: 13px;">Eğer bu talebi siz oluşturmadıysanız, bu e-postayı görmezden gelebilirsiniz.</p>
        </div>
      `,
    });

    res.status(200).json({ message: 'Sıfırlama kodu e-postanıza gönderildi' });
  } catch (error) {
    console.error('forgotPassword hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// @desc    Şifre sıfırlama - OTP doğrula ve şifreyi güncelle
// @route   POST /api/users/reset-password
// @access  Public
const resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return res.status(400).json({ message: 'E-posta, kod ve yeni şifre gereklidir' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
    }

    // Kod doğru mu?
    if (user.resetCode !== code) {
      return res.status(400).json({ message: 'Geçersiz doğrulama kodu' });
    }

    // Kod süresi dolmuş mu?
    if (!user.resetCodeExpiry || user.resetCodeExpiry < new Date()) {
      return res.status(400).json({ message: 'Doğrulama kodunun süresi dolmuş, yeni kod isteyin' });
    }

    // Yeni şifreyi hash'le
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);

    // Kullanılan kodu temizle
    user.resetCode = null;
    user.resetCodeExpiry = null;
    await user.save();

    res.status(200).json({ message: 'Şifreniz başarıyla güncellendi' });
  } catch (error) {
    console.error('resetPassword hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

module.exports = {
  registerUser,
  authUser,
  forgotPassword,
  resetPassword,
};
