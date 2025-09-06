const express = require('express');
const TransactionController = require('../controllers/TransactionController');
const { authenticateUser } = require('../middleware/authUser');
const { authenticateAdmin } = require('../middleware/authAdmin');

const router = express.Router();

// Rute untuk membuat transaksi
router.post('/', authenticateUser, TransactionController.create);

// routes/transactionRoutes.js
router.get('/admin', async (req, res) => {
  try {
    const { search = '', status = 'all', sort = 'terbaru' } = req.query;

    const transactions = await TransactionController.getFilteredTransactions({
      search,
      status,
      sort,
    });

    res.status(200).json({
      status: 'success',
      data: transactions,
    });
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal mengambil data transaksi',
    });
  }
});

// Endpoint admin (tambahkan query params)
router.get('/admin', authenticateAdmin, TransactionController.getAll);
// Rute untuk mendapatkan detail transaksi berdasarkan orderId (Admin)
router.get('/admin/:orderId', authenticateAdmin, async (req, res) => {
  try {
    const { orderId } = req.params;

    // Menggunakan fungsi dari model untuk mendapatkan detail transaksi
    const transaction = await Transaction.findByOrderId(orderId);

    if (!transaction) {
      return res.status(404).json({
        status: 'error',
        message: 'Transaksi tidak ditemukan',
      });
    }

    // Jika perlu mendapatkan informasi customer, tambahkan join dengan tabel users
    const connection = await mysql.createConnection(dbConfig);
    const [transactionsWithCustomer] = await connection.execute(
      `SELECT t.*, u.nama_lengkap as customer_name 
       FROM transactions t 
       LEFT JOIN users u ON t.user_id = u.user_id 
       WHERE t.order_id = ?`,
      [orderId]
    );
    await connection.end();

    const transactionDetail = transactionsWithCustomer[0];

    // Parse item_details jika berupa string JSON
    if (
      transactionDetail.item_details &&
      typeof transactionDetail.item_details === 'string'
    ) {
      try {
        transactionDetail.item_details = JSON.parse(
          transactionDetail.item_details
        );
      } catch (e) {
        console.error('Error parsing item_details:', e);
        transactionDetail.item_details = [];
      }
    }

    res.status(200).json({
      status: 'success',
      data: transactionDetail,
    });
  } catch (error) {
    console.error('Error fetching transaction detail:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal mengambil detail transaksi',
    });
  }
});

// Endpoint user (tambahkan query params)
// router.get('/user', authenticateUser, TransactionController.getAllByUserId);
router.get('/', authenticateUser, TransactionController.getUserTransactions);
router.get(
  '/:orderId/detail',
  authenticateUser,
  TransactionController.getTransactionDetail
);
router.get(
  '/:orderId/token',
  authenticateUser,
  TransactionController.getSnapToken
);

router.put(
  '/:transaction_id/status',
  authenticateAdmin,
  TransactionController.updateStatus
);
router.get('/count', authenticateAdmin, async (req, res) => {
  try {
    const count = await Transaction.getCount();
    res.json({ total: count });
  } catch (error) {
    res.status(500).json({ message: 'Error getting transaction count' });
  }
});
router.get('/recent', authenticateAdmin, async (req, res) => {
  try {
    const transactions = await Transaction.getRecent(5);
    res.json(transactions);
  } catch (error) {
    res.status(500).json({ message: 'Error getting recent transactions' });
  }
});

// File: routes/transactionRoutes.js
router.post(
  '/notification',
  express.json({ type: 'application/json' }),
  TransactionController.handleNotification
);

module.exports = router;
