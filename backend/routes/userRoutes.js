const express = require('express');
const router = express.Router();
const { registerUser, authUser } = require('../controllers/userController');

// Kullanıcı Kaydı Rotası
router.post('/register', registerUser);

// Kullanıcı Girişi Rotası
router.post('/login', authUser);

module.exports = router;
