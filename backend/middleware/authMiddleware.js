const jwt = require('jsonwebtoken');
const User = require('../models/User');

// TODO: Token doğrulama ve kullanıcı yetkilendirme (Protect route) Hafta 2'de eklenecek
const protect = async (req, res, next) => {
  // Authorization mantığı gelecek
  next();
};

module.exports = { protect };
