// products.js - Script untuk mengelola produk dengan fitur kategori

let categories = [];
let products = [];

document.addEventListener('DOMContentLoaded', async () => {
  if (!Auth.isAuthenticated()) {
    window.location.href = '/admin/login';
    return;
  }

  await loadHeader();
  await loadCategories();
  await loadProducts();
  setupEventListeners();
});

async function loadHeader() {
  try {
    const header = await fetch('/admin/partials/header.html').then((res) =>
      res.text()
    );
    document.getElementById('header-container').innerHTML = header;
    document.getElementById('logoutBtn').addEventListener('click', Auth.logout);
  } catch (error) {
    console.error('Error loading header:', error);
  }
}

async function loadCategories() {
  try {
    const token = Auth.getToken();
    const response = await fetch('/api/products/categories', {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (!response.ok) throw new Error('Gagal memuat kategori');

    categories = await response.json();

    // Isi dropdown kategori di form
    const categorySelect = document.getElementById('productCategory');
    categorySelect.innerHTML =
      '<option value="">Pilih Kategori</option>' +
      categories
        .map(
          (cat) =>
            `<option value="${cat.category_id}">${cat.nama_kategori}</option>`
        )
        .join('');

    // Isi dropdown kategori di filter
    const categoryFilter = document.getElementById('categoryFilter');
    categoryFilter.innerHTML =
      '<option value="">Semua Kategori</option>' +
      categories
        .map(
          (cat) =>
            `<option value="${cat.category_id}">${cat.nama_kategori}</option>`
        )
        .join('');
  } catch (error) {
    showAlert('danger', 'Gagal memuat kategori: ' + error.message);
  }
}

async function loadProducts() {
  try {
    const token = Auth.getToken();
    const categoryFilter = document.getElementById('categoryFilter').value;
    const searchQuery = document.getElementById('searchInput').value;

    let url = '/api/products';
    const params = new URLSearchParams();

    if (categoryFilter) params.append('category_id', categoryFilter);
    if (searchQuery) params.append('search', searchQuery);

    if (params.toString()) url += '?' + params.toString();

    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (!response.ok) throw new Error('Gagal memuat produk');

    products = await response.json();
    renderProducts(products);
  } catch (error) {
    showAlert('danger', 'Gagal memuat data produk: ' + error.message);
  }
}

function renderProducts(products) {
  const tbody = document.getElementById('productsTableBody');
  tbody.innerHTML =
    products.length === 0
      ? `
                <tr>
                    <td colspan="6" class="text-center">Tidak ada produk tersedia</td>
                </tr>
            `
      : products
          .map(
            (product) => `
                <tr>
                    <td>
                        ${
                          product.image_url
                            ? `<img src="${product.image_url}" alt="${product.nama_produk}" class="product-thumbnail">`
                            : '<i class="fas fa-image text-muted"></i>'
                        }
                    </td>
                    <td>${product.nama_produk}</td>
                    <td>Rp${product.harga.toLocaleString()}</td>
                    <td>${product.stok}</td>
                    <td>
                        <span class="badge bg-primary category-badge">
                            ${product.nama_kategori || 'Tidak ada kategori'}
                        </span>
                    </td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary edit-btn" data-id="${
                          product.product_id
                        }">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger delete-btn" data-id="${
                          product.product_id
                        }">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `
          )
          .join('');

  // Add event listeners
  document.querySelectorAll('.edit-btn').forEach((btn) => {
    btn.addEventListener('click', () => showEditForm(btn.dataset.id));
  });

  document.querySelectorAll('.delete-btn').forEach((btn) => {
    btn.addEventListener('click', () => deleteProduct(btn.dataset.id));
  });
}

function setupEventListeners() {
  const modalElement = document.getElementById('productModal');
  const modal = bootstrap.Modal.getOrCreateInstance(modalElement);

  // Add Product Button
  document.getElementById('addProductBtn').addEventListener('click', () => {
    document.getElementById('modalTitle').textContent = 'Tambah Produk Baru';
    document.getElementById('productForm').reset();
    document.getElementById('productId').value = '';
    document.getElementById('imagePreview').innerHTML = '';
    modal.show();
  });

  // Form Submission
  document
    .getElementById('productForm')
    .addEventListener('submit', async (e) => {
      e.preventDefault();
      const isEdit = document.getElementById('productId').value !== '';

      try {
        const formData = new FormData();
        formData.append(
          'nama_produk',
          document.getElementById('productName').value
        );
        formData.append(
          'deskripsi',
          document.getElementById('productDescription').value
        );
        formData.append('harga', document.getElementById('productPrice').value);
        formData.append('stok', document.getElementById('productStock').value);
        formData.append(
          'category_id',
          document.getElementById('productCategory').value
        );

        const imageInput = document.getElementById('productImage');
        if (imageInput.files[0]) {
          formData.append('image', imageInput.files[0]);
        }

        const token = Auth.getToken();
        const url = isEdit
          ? `/api/products/${document.getElementById('productId').value}`
          : '/api/products';

        const response = await fetch(url, {
          method: isEdit ? 'PUT' : 'POST',
          headers: { Authorization: `Bearer ${token}` },
          body: formData,
        });

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(errorText);
        }

        await loadProducts();
        modal.hide();
        showAlert(
          'success',
          `Produk berhasil ${isEdit ? 'diperbarui' : 'ditambahkan'}`
        );
      } catch (error) {
        console.error('Error:', error);
        showAlert(
          'danger',
          `Gagal ${isEdit ? 'memperbarui' : 'menambahkan'} produk: ${
            error.message
          }`
        );
      }
    });

  // Image Preview
  document
    .getElementById('productImage')
    .addEventListener('change', function (e) {
      const file = e.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (event) => {
          document.getElementById('imagePreview').innerHTML = `
                        <img src="${event.target.result}" class="img-thumbnail" style="max-height: 150px;">
                    `;
        };
        reader.readAsDataURL(file);
      }
    });

  // Filter events
  document
    .getElementById('categoryFilter')
    .addEventListener('change', loadProducts);
  document
    .getElementById('searchInput')
    .addEventListener('input', debounce(loadProducts, 300));
  document.getElementById('resetFilterBtn').addEventListener('click', () => {
    document.getElementById('categoryFilter').value = '';
    document.getElementById('searchInput').value = '';
    loadProducts();
  });
}

async function showEditForm(productId) {
  try {
    const token = Auth.getToken();
    const response = await fetch(`/api/products/${productId}`, {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (!response.ok) throw new Error('Gagal memuat data produk');

    const product = await response.json();

    // Isi form
    document.getElementById('modalTitle').textContent = 'Edit Produk';
    document.getElementById('productId').value = product.product_id;
    document.getElementById('productName').value = product.nama_produk;
    document.getElementById('productDescription').value = product.deskripsi;
    document.getElementById('productPrice').value = product.harga;
    document.getElementById('productStock').value = product.stok;
    document.getElementById('productCategory').value =
      product.category_id || '';

    // Preview gambar
    document.getElementById('imagePreview').innerHTML = product.image_url
      ? `<img src="${product.image_url}" class="img-thumbnail" style="max-height: 150px;">`
      : '';

    const modal = bootstrap.Modal.getOrCreateInstance(
      document.getElementById('productModal')
    );
    modal.show();
  } catch (error) {
    showAlert('danger', 'Gagal memuat data produk: ' + error.message);
  }
}

async function deleteProduct(productId) {
  if (!confirm('Apakah Anda yakin ingin menghapus produk ini?')) return;

  try {
    const token = Auth.getToken();
    const response = await fetch(`/api/products/${productId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
    });

    if (!response.ok) throw new Error('Gagal menghapus produk');

    await loadProducts();
    showAlert('success', 'Produk berhasil dihapus');
  } catch (error) {
    showAlert('danger', 'Gagal menghapus produk: ' + error.message);
  }
}

function showAlert(type, message) {
  // Hapus alert sebelumnya jika ada
  const existingAlert = document.querySelector('.alert');
  if (existingAlert) {
    existingAlert.remove();
  }

  const alertDiv = document.createElement('div');
  alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed top-0 end-0 m-3`;
  alertDiv.style.zIndex = '1000';
  alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
  document.body.appendChild(alertDiv);

  setTimeout(() => alertDiv.remove(), 5000);
}

// Utility function for debouncing
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}
