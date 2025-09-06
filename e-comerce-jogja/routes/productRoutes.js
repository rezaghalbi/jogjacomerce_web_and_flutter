const express = require('express');
const ProductController = require('../controllers/ProductController');
const { authenticateAdmin } = require('../middleware/authAdmin');
const { authenticateUser } = require('../middleware/authUser');

const router = express.Router();

// Public routes
router.get('/', ProductController.getAll);
router.get('/categories', ProductController.getCategories); // Endpoint untuk mendapatkan semua kategori
router.get('/category/:category_id', ProductController.getByCategory); // Endpoint untuk mendapatkan produk berdasarkan kategori
router.get('/:product_id', ProductController.getById);
router.get('/search', ProductController.search);

// Admin routes - require authentication
router.use(authenticateAdmin);
router.post('/', ProductController.create);
router.put('/:product_id', ProductController.update);
router.delete('/:product_id', ProductController.deleteProduct);

// Count endpoint
router.get('/count', async (req, res) => {
  try {
    const count = await Product.count();
    res.json({ total: count });
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil jumlah produk' });
  }
});

// Debug endpoint - hanya untuk development
router.get('/debug', async (req, res) => {
  try {
    // Dapatkan semua data produk dengan detail
    const products = await Product.findAll();

    // Dapatkan informasi database
    const connection = await mysql.createConnection(dbConfig);
    const [dbInfo] = await connection.execute(
      'SELECT VERSION() as version, DATABASE() as dbname'
    );

    // Dapatkan informasi tabel
    const [tableInfo] = await connection.execute(`
      SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = DATABASE()
    `);

    await connection.end();

    res.json({
      status: 'success',
      data: {
        productsCount: products.length,
        sampleProduct: products[0] || null,
        database: dbInfo[0],
        tables: tableInfo,
      },
    });
  } catch (error) {
    console.error('Debug endpoint error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Debug failed',
      error: {
        message: error.message,
        stack: error.stack,
      },
    });
  }
});

module.exports = router;
