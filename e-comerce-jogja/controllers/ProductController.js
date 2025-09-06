const Product = require('../models/Product');
const formidable = require('formidable');
const path = require('path');
const axios = require('axios');
const fs = require('fs');

// Fungsi upload gambar ke Imgur
async function uploadImageToImgur(filePath) {
  const imageData = fs.readFileSync(filePath, { encoding: 'base64' });

  const response = await axios.post(
    'https://api.imgur.com/3/image',
    { image: imageData, type: 'base64' },
    {
      headers: {
        Authorization: `Client-ID ${process.env.IMGUR_CLIENT_ID}`,
      },
    }
  );

  if (response.data && response.data.success) {
    return response.data.data.link;
  } else {
    throw new Error('Failed to upload image to Imgur');
  }
}

class ProductController {
  static async create(req, res) {
    const form = new formidable.IncomingForm();
    form.uploadDir = path.join(__dirname, '../uploads');
    form.keepExtensions = true;

    form.parse(req, async (err, fields, files) => {
      if (!files.image) {
        console.warn('⚠️ No image file found in request');
      } else {
        console.log('✅ Image file detected:', files.image);
      }

      // Ambil nilai dari fields
      const nama_produk = fields.nama_produk?.[0];
      const deskripsi = fields.deskripsi?.[0];
      const harga = fields.harga?.[0];
      const stok = fields.stok?.[0];
      const category_id = fields.category_id?.[0]; // Tambahkan category_id
      const admin_id = req.adminId;

      console.log('🧾 Parsed fields:', {
        nama_produk,
        deskripsi,
        harga,
        stok,
        category_id,
        admin_id,
      });

      // Validasi input
      if (
        !nama_produk ||
        !deskripsi ||
        !harga ||
        !stok ||
        !admin_id ||
        !category_id
      ) {
        console.warn('⚠️ Missing required fields');
        return res.status(400).json({ message: 'All fields are required' });
      }

      // Konversi ke tipe angka
      const hargaNumber = parseFloat(harga);
      const stokNumber = parseInt(stok);
      const categoryIdNumber = parseInt(category_id);

      if (isNaN(hargaNumber) || isNaN(stokNumber) || isNaN(categoryIdNumber)) {
        console.warn('⚠️ Harga/Stok/Category bukan angka valid:', {
          harga,
          stok,
          category_id,
        });
        return res
          .status(400)
          .json({ message: 'Price, stock and category must be valid numbers' });
      }

      let imageUrl = null;

      // Proses upload gambar jika ada
      if (files.image) {
        const file = Array.isArray(files.image) ? files.image[0] : files.image;
        const oldPath = file.filepath || file.path;
        console.log('📁 files.images:', files.image);
        console.log('📁 file:', file);
        console.log('📁 oldPath:', oldPath);

        if (!oldPath) {
          console.warn('⚠️ No filepath in uploaded file');
          return res.status(400).json({ message: 'Invalid file upload' });
        }

        try {
          imageUrl = await uploadImageToImgur(oldPath);
          console.log('✅ Image uploaded to:', imageUrl);
        } catch (err) {
          console.error('❌ Upload error:', err);
          return res
            .status(500)
            .json({ message: 'Upload failed', error: err.message });
        }
      } else {
        console.warn('⚠️ No image file found in request');
      }

      try {
        const productData = {
          nama_produk,
          deskripsi,
          harga: hargaNumber,
          stok: stokNumber,
          admin_id,
          category_id: categoryIdNumber,
          image_url: imageUrl,
        };

        console.log('📦 Creating product with data:', productData);

        const productId = await Product.create(productData);

        res.status(201).json({
          message: 'Product created successfully',
          productId,
        });
      } catch (error) {
        console.error('❌ Error creating product:', error);
        res.status(500).json({
          message: 'Error creating product',
          error: error.message,
        });
      }
    });
  }

  static async getAll(req, res) {
    try {
      // Mendukung filter melalui query parameters
      const { search, category_id, minPrice, maxPrice, sortBy, order } =
        req.query;

      if (search || category_id || minPrice || maxPrice || sortBy) {
        // Gunakan filtered products jika ada parameter filter
        const filters = {
          search,
          category_id: category_id ? parseInt(category_id) : undefined,
          minPrice: minPrice ? parseFloat(minPrice) : undefined,
          maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
          sortBy,
          order,
        };

        const products = await Product.getFilteredProducts(filters);
        res.status(200).json(products);
      } else {
        // Ambil semua produk jika tidak ada filter
        const products = await Product.findAll();
        res.status(200).json(products);
      }
    } catch (error) {
      console.error('Error fetching products:', error);
      res
        .status(500)
        .json({ message: 'Error fetching products', error: error.message });
    }
  }

  static async getById(req, res) {
    try {
      const product = await Product.findById(req.params.product_id);
      if (!product) {
        return res.status(404).json({ message: 'Produk tidak ditemukan' });
      }
      res.json(product);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  static async update(req, res) {
    const { product_id } = req.params;

    const form = new formidable.IncomingForm();
    form.uploadDir = path.join(__dirname, '../uploads');
    form.keepExtensions = true;

    form.parse(req, async (err, fields, files) => {
      if (!files.image) {
        console.warn('⚠️ No image file found in request');
      } else {
        console.log('✅ Image file detected:', files.image);
      }

      console.log('✅ Parsed fields:', fields);
      console.log('📁 files:', files);

      const { nama_produk, deskripsi, harga, stok, category_id } = fields;

      if (!nama_produk || !deskripsi || !harga || !stok || !category_id) {
        return res.status(400).json({ message: 'Semua field wajib diisi' });
      }

      const hargaNumber = parseFloat(harga);
      const stokNumber = parseInt(stok);
      const categoryIdNumber = parseInt(category_id);

      if (isNaN(hargaNumber) || isNaN(stokNumber) || isNaN(categoryIdNumber)) {
        return res
          .status(400)
          .json({ message: 'Harga, stok, dan kategori harus angka valid' });
      }

      let imageUrl = null;

      if (files.image) {
        const file = Array.isArray(files.image) ? files.image[0] : files.image;
        const oldPath = file.filepath || file.path;
        console.log('📁 files.images:', files.image);
        console.log('📁 file:', file);
        console.log('📁 oldPath:', oldPath);

        if (!oldPath) {
          console.warn('⚠️ No filepath in uploaded file');
          return res.status(400).json({ message: 'Invalid file upload' });
        }

        console.log('🖼️ Uploading image from path:', oldPath);

        try {
          imageUrl = await uploadImageToImgur(oldPath);
          console.log('✅ Image uploaded successfully:', imageUrl);
        } catch (uploadError) {
          console.error('❌ Error uploading image:', uploadError);
          return res.status(500).json({
            message: 'Error uploading image',
            error: uploadError.message,
          });
        }
      }

      try {
        const product = await Product.findById(product_id);
        if (!product) {
          return res.status(404).json({ message: 'Produk tidak ditemukan' });
        }

        // Data yang akan diupdate
        const updatedData = {
          nama_produk: nama_produk[0],
          deskripsi: deskripsi[0],
          harga: parseInt(harga[0]),
          stok: parseInt(stok[0]),
          category_id: parseInt(category_id[0]),
          image_url: imageUrl || product.image_url, // Gunakan URL lama jika tidak ada gambar baru
        };

        // Panggil method update di model
        await Product.update(product_id, updatedData);

        res.status(200).json({
          message: 'Produk berhasil diperbarui',
          product: { product_id, ...updatedData },
        });
      } catch (error) {
        console.error('❌ Error updating product:', error);
        res.status(500).json({
          message: 'Error updating product',
          error: error.message,
        });
      }
    });
  }

  static async deleteProduct(req, res) {
    try {
      const { product_id } = req.params;

      if (!product_id) {
        return res.status(400).json({ message: 'Product ID is required' });
      }

      const result = await Product.delete(product_id);

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Product not found' });
      }

      res.status(200).json({ message: 'Product deleted successfully' });
    } catch (error) {
      console.error('❌ Error deleting product:', error);
      res.status(500).json({
        message: 'Failed to delete product',
        error: error.message,
      });
    }
  }

  static async search(req, res) {
    try {
      const { keyword } = req.query;
      if (!keyword) {
        return res.status(400).json({ message: 'Keyword is required' });
      }

      const products = await Product.search(keyword);
      res.status(200).json(products);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  // Method baru untuk mendapatkan semua kategori
  static async getCategories(req, res) {
    try {
      const categories = await Product.getCategories();
      res.status(200).json(categories);
    } catch (error) {
      console.error('Error fetching categories:', error);
      res.status(500).json({
        message: 'Error fetching categories',
        error: error.message,
      });
    }
  }

  // Method baru untuk mendapatkan produk berdasarkan kategori
  static async getByCategory(req, res) {
    try {
      const { category_id } = req.params;

      if (!category_id) {
        return res.status(400).json({ message: 'Category ID is required' });
      }

      const products = await Product.findByCategory(category_id);
      res.status(200).json(products);
    } catch (error) {
      console.error('Error fetching products by category:', error);
      res.status(500).json({
        message: 'Error fetching products by category',
        error: error.message,
      });
    }
  }
}

module.exports = ProductController;
