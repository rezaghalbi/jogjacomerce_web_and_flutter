const mysql = require('mysql2/promise');
const dbConfig = require('../config/dbConfig');

class Product {
  static async create(productData) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const [result] = await connection.execute(
        'INSERT INTO products (nama_produk, deskripsi, harga, stok, admin_id, image_url, category_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          productData.nama_produk,
          productData.deskripsi,
          productData.harga,
          productData.stok,
          productData.admin_id,
          productData.image_url,
          productData.category_id, // Tambahkan category_id
        ]
      );
      return result.insertId;
    } catch (error) {
      console.error('Error in Product.create:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  static async findAll() {
    const connection = await mysql.createConnection(dbConfig);
    try {
      // Join dengan tabel categories
      const [rows] = await connection.execute(`
        SELECT p.*, c.nama_kategori 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.category_id
        ORDER BY p.created_at DESC
      `);
      return rows;
    } catch (error) {
      console.error('Error in Product.findAll:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  static async findById(product_id) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      // Join dengan tabel categories
      const [rows] = await connection.execute(
        `
        SELECT p.*, c.nama_kategori 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.category_id
        WHERE p.product_id = ?
      `,
        [product_id]
      );
      return rows[0];
    } catch (error) {
      console.error('Error in Product.findById:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  static async update(product_id, data) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const { nama_produk, deskripsi, harga, stok, image_url, category_id } =
        data;

      const query = `
        UPDATE products 
        SET nama_produk = ?, deskripsi = ?, harga = ?, stok = ?, image_url = ?, category_id = ?
        WHERE product_id = ?
      `;

      const values = [
        nama_produk,
        deskripsi,
        harga,
        stok,
        image_url,
        category_id,
        product_id,
      ];

      console.log('🔎 Update values:', values);
      const [result] = await connection.execute(query, values);
      return result;
    } catch (error) {
      console.error('Error in Product.update:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  static async delete(product_id) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const [result] = await connection.execute(
        'DELETE FROM products WHERE product_id = ?',
        [product_id]
      );
      return result;
    } catch (error) {
      console.error('Error in Product.delete:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  static async count() {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const [rows] = await connection.execute(
        'SELECT COUNT(*) as total FROM products'
      );
      return rows[0].total;
    } catch (error) {
      console.error('Error in Product.count:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  static async search(keyword) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const [rows] = await connection.execute(
        `SELECT p.*, c.nama_kategori 
         FROM products p 
         LEFT JOIN categories c ON p.category_id = c.category_id
         WHERE p.nama_produk LIKE ? OR p.deskripsi LIKE ?`,
        [`%${keyword}%`, `%${keyword}%`]
      );
      return rows;
    } catch (error) {
      console.error('Error in Product.search:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  static async addToCart(cartData) {
    // Validasi stok
    const product = await Product.findById(cartData.product_id);
    if (product.stok < cartData.jumlah) {
      throw new Error('Stok tidak mencukupi');
    }
  }

  static async updateStock(productId, quantity) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const [result] = await connection.execute(
        `UPDATE products 
         SET stok = stok - ? 
         WHERE product_id = ?`,
        [quantity, productId]
      );
      return result;
    } catch (error) {
      console.error('Error in Product.updateStock:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  // Method baru untuk mendapatkan semua kategori
  static async getCategories() {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const [rows] = await connection.execute(
        'SELECT * FROM categories ORDER BY nama_kategori'
      );
      return rows;
    } catch (error) {
      console.error('Error in Product.getCategories:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  // Method baru untuk mendapatkan produk berdasarkan kategori
  static async findByCategory(category_id) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      const [rows] = await connection.execute(
        `
        SELECT p.*, c.nama_kategori 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.category_id
        WHERE p.category_id = ?
        ORDER BY p.created_at DESC
      `,
        [category_id]
      );
      return rows;
    } catch (error) {
      console.error('Error in Product.findByCategory:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }

  // Method baru untuk mendapatkan produk dengan filter (harga, kategori, dll)
  static async getFilteredProducts(filters = {}) {
    const connection = await mysql.createConnection(dbConfig);
    try {
      let query = `
        SELECT p.*, c.nama_kategori 
        FROM products p 
        LEFT JOIN categories c ON p.category_id = c.category_id 
        WHERE 1=1
      `;
      const values = [];

      if (filters.search) {
        query += ` AND (p.nama_produk LIKE ? OR p.deskripsi LIKE ?)`;
        values.push(`%${filters.search}%`, `%${filters.search}%`);
      }

      if (filters.category_id) {
        query += ` AND p.category_id = ?`;
        values.push(filters.category_id);
      }

      if (filters.minPrice !== undefined && !isNaN(filters.minPrice)) {
        query += ` AND p.harga >= ?`;
        values.push(filters.minPrice);
      }

      if (filters.maxPrice !== undefined && !isNaN(filters.maxPrice)) {
        query += ` AND p.harga <= ?`;
        values.push(filters.maxPrice);
      }

      // Sorting
      if (filters.sortBy) {
        const validSortColumns = ['nama_produk', 'harga', 'created_at', 'stok'];
        const validOrder = ['ASC', 'DESC'];

        if (validSortColumns.includes(filters.sortBy)) {
          const order = validOrder.includes(filters.order?.toUpperCase())
            ? filters.order.toUpperCase()
            : 'ASC';
          query += ` ORDER BY p.${filters.sortBy} ${order}`;
        }
      } else {
        query += ` ORDER BY p.created_at DESC`;
      }

      const [rows] = await connection.execute(query, values);
      return rows;
    } catch (error) {
      console.error('Error in Product.getFilteredProducts:', error);
      throw error;
    } finally {
      await connection.end();
    }
  }
}

module.exports = Product;
