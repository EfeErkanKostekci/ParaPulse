const Transaction = require('../models/Transaction');

// @desc    Tüm harcamaları getir (Sadece o kullanıcıya ait)
// @route   GET /api/transactions
// @access  Private
const getTransactions = async (req, res) => {
  try {
    const transactions = await Transaction.find({ user: req.user.id }).sort({ date: -1 });
    res.status(200).json(transactions);
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// @desc    Harcama Ekle
// @route   POST /api/transactions
// @access  Private
const addTransaction = async (req, res) => {
  try {
    const { amount, category, type, date } = req.body;

    if (!amount || !category || !type) {
      return res.status(400).json({ message: 'Lütfen tüm zorunlu alanları doldurun' });
    }

    const transaction = await Transaction.create({
      user: req.user.id,
      amount,
      category,
      type,
      date: date || Date.now(),
    });

    res.status(201).json(transaction);
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// @desc    Harcama Güncelle
// @route   PUT /api/transactions/:id
// @access  Private
const updateTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id);

    if (!transaction) {
      return res.status(404).json({ message: 'Harcama bulunamadı' });
    }

    // Harcamanın sahibi isteği atan kullanıcı mı?
    if (transaction.user.toString() !== req.user.id) {
      return res.status(401).json({ message: 'Yetkilendirme reddedildi' });
    }

    const updatedTransaction = await Transaction.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    res.status(200).json(updatedTransaction);
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// @desc    Harcama Sil
// @route   DELETE /api/transactions/:id
// @access  Private
const deleteTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id);

    if (!transaction) {
      return res.status(404).json({ message: 'Harcama bulunamadı' });
    }

    // Harcamanın sahibi isteği atan kullanıcı mı?
    if (transaction.user.toString() !== req.user.id) {
      return res.status(401).json({ message: 'Yetkilendirme reddedildi' });
    }

    await transaction.deleteOne();

    res.status(200).json({ id: req.params.id });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

module.exports = {
  getTransactions,
  addTransaction,
  updateTransaction,
  deleteTransaction,
};
