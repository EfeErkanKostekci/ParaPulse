const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  amount: {
    type: Number,
    required: [true, 'Lütfen bir miktar girin']
  },
  category: {
    type: String,
    required: [true, 'Lütfen bir kategori girin']
  },
  type: {
    type: String,
    enum: ['income', 'expense'],
    required: [true, 'Lütfen işlem tipini (income/expense) belirtin']
  },
  date: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

module.exports = mongoose.model('Transaction', transactionSchema);
