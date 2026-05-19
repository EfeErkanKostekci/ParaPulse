const express = require('express');
const router = express.Router();
const { registerUser, authUser, forgotPassword, resetPassword } = require('../controllers/userController');

// Kullanıcı Kaydı Rotası
router.post('/register', registerUser);

// Kullanıcı Girişi Rotası
router.post('/login', authUser);

// Şifremi Unuttum Rotası
router.post('/forgot-password', forgotPassword);

// Şifre Sıfırlama (OTP Doğrulama) Rotası
router.post('/reset-password', resetPassword);

module.exports = router;
