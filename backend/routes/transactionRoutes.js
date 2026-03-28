const express = require('express');
const router = express.Router();
const { getTransactions } = require('../controllers/transactionController');
// const { protect } = require('../middleware/authMiddleware');

// Transaction Rotaları (İleride protect middleware'i eklenecek)
// router.get('/', protect, getTransactions);

module.exports = router;
