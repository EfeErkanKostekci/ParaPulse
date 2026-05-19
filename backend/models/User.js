const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Lütfen isminizi girin']
  },
  email: {
    type: String,
    required: [true, 'Lütfen e-posta adresinizi girin'],
    unique: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Lütfen geçerli bir e-posta adresi girin'
    ]
  },
  password: {
    type: String,
    required: [true, 'Lütfen şifrenizi girin'],
    minlength: 6
  },
  // Şifre sıfırlama alanları
  resetCode: {
    type: String,
    default: null
  },
  resetCodeExpiry: {
    type: Date,
    default: null
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
