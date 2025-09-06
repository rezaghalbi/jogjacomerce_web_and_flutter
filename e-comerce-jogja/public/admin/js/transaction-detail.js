import { loadHeader } from './admin-common.js';

document.addEventListener('DOMContentLoaded', async () => {
  if (!Auth.isAuthenticated()) {
    window.location.href = '/admin/login';
    return;
  }

  await loadHeader();
  await loadTransactionDetail();
});

// Fungsi untuk menampilkan/menyembunyikan loading indicator
function showLoading(show) {
  // Coba cari elemen loading yang sudah ada
  let loadingElement = document.getElementById('loadingIndicator');

  // Jika tidak ada, buat elemen loading baru
  if (!loadingElement) {
    loadingElement = document.createElement('div');
    loadingElement.id = 'loadingIndicator';
    loadingElement.className =
      'position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center';
    loadingElement.style.background = 'rgba(255, 255, 255, 0.8)';
    loadingElement.style.zIndex = '1000';
    loadingElement.innerHTML = `
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    `;
    document.body.appendChild(loadingElement);
  }

  // Tampilkan atau sembunyikan loading
  loadingElement.style.display = show ? 'flex' : 'none';
}

// Fungsi untuk menampilkan alert
function showAlert(type, message) {
  // Hapus alert sebelumnya jika ada
  const existingAlert = document.querySelector('.alert.alert-dismissible');
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

async function loadTransactionDetail() {
  try {
    showLoading(true);

    const token = Auth.getToken();
    const urlParams = new URLSearchParams(window.location.search);
    const orderId = urlParams.get('orderId');

    if (!orderId) {
      showAlert('danger', 'Order ID tidak ditemukan');
      return;
    }

    const response = await fetch(`/api/transactions/admin/${orderId}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    // Handle token expired
    if (response.status === 401) {
      showAlert('danger', 'Sesi telah berakhir. Silakan login kembali.');
      setTimeout(() => {
        Auth.logout();
        window.location.href = '/admin/login';
      }, 2000);
      return;
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(
        errorData.message || `HTTP error! status: ${response.status}`
      );
    }

    const data = await response.json();
    console.log('Detail transaksi:', data);

    const transaction = data.data || data;

    if (!transaction) {
      throw new Error('Data transaksi tidak ditemukan dalam response');
    }

    renderTransactionDetail(transaction);
  } catch (error) {
    console.error('Error loading transaction detail:', error);

    if (error.message.includes('Failed to fetch')) {
      showAlert(
        'danger',
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'
      );
    } else {
      showAlert('danger', 'Gagal memuat detail transaksi: ' + error.message);
    }

    document.getElementById('itemDetails').innerHTML = `
      <div class="alert alert-danger">
        <h5>Error Memuat Data</h5>
        <p>${error.message}</p>
        <button class="btn btn-sm btn-outline-secondary mt-2" onclick="window.history.back()">
          <i class="fas fa-arrow-left me-1"></i> Kembali
        </button>
      </div>
    `;
  } finally {
    showLoading(false);
  }
}

function renderTransactionDetail(transaction) {
  console.log('Transaction data:', transaction);

  // Isi informasi transaksi
  document.getElementById('orderId').textContent = transaction.order_id || '-';
  document.getElementById('orderIdDisplay').textContent =
    transaction.order_id || '-';

  // Handle berbagai format nama customer
  let customerName = 'Tidak diketahui';
  let customerEmail = 'Tidak diketahui';
  let customerPhone = 'Tidak diketahui';

  if (transaction.customer_name) {
    customerName = transaction.customer_name;
  } else if (transaction.user_id) {
    customerName = `User ${transaction.user_id}`;
  }

  if (transaction.email) {
    customerEmail = transaction.email;
  }

  if (transaction.no_telepon) {
    customerPhone = transaction.no_telepon;
  }

  document.getElementById('customerName').textContent = customerName;
  document.getElementById('customerEmail').textContent = customerEmail;
  document.getElementById('customerPhone').textContent = customerPhone;

  document.getElementById('grossAmount').textContent = transaction.gross_amount
    ? `Rp${transaction.gross_amount.toLocaleString('id-ID')}`
    : 'Rp0';

  const statusElement = document.getElementById('paymentStatus');
  statusElement.textContent = getStatusLabel(transaction.payment_status);
  statusElement.className = `status-badge status-${transaction.payment_status}`;

  document.getElementById('paymentMethod').textContent =
    transaction.payment_method || 'Tidak diketahui';

  // Format tanggal transaksi
  let transactionTime = '-';
  if (transaction.transaction_time) {
    transactionTime = new Date(transaction.transaction_time).toLocaleString(
      'id-ID'
    );
  } else if (transaction.created_at) {
    transactionTime = new Date(transaction.created_at).toLocaleString('id-ID');
  }
  document.getElementById('transactionTime').textContent = transactionTime;

  document.getElementById('adminNotes').textContent =
    transaction.admin_notes || 'Tidak ada catatan';

  // Parse and render item details
  renderItemDetails(transaction.item_details, transaction);

  // Add action buttons if needed
  addActionButtons(transaction.payment_status, transaction.order_id);
}

function renderItemDetails(itemDetails, transaction) {
  const container = document.getElementById('itemDetails');

  try {
    // Handle berbagai format item details
    let items = [];

    if (typeof itemDetails === 'string') {
      // Jika berupa string JSON, coba parse
      try {
        items = JSON.parse(itemDetails);
      } catch (e) {
        // Jika parsing gagal, tampilkan sebagai teks
        container.innerHTML = `
          <div class="alert alert-warning">
            <h5>Format Item Details Tidak Dikenali</h5>
            <pre class="bg-light p-3">${itemDetails}</pre>
          </div>
        `;
        return;
      }
    } else if (Array.isArray(itemDetails)) {
      // Jika sudah array, gunakan langsung
      items = itemDetails;
    } else {
      // Jika tidak ada data item
      container.innerHTML =
        '<p class="text-center text-muted">Tidak ada data item</p>';
      return;
    }

    if (!items || items.length === 0) {
      container.innerHTML =
        '<p class="text-center text-muted">Tidak ada item</p>';
      return;
    }

    // Render tabel items
    container.innerHTML = `
      <div class="table-responsive">
        <table class="table table-striped">
          <thead class="table-light">
            <tr>
              <th>Nama Produk</th>
              <th class="text-center">Jumlah</th>
              <th class="text-end">Harga Satuan</th>
              <th class="text-end">Subtotal</th>
            </tr>
          </thead>
          <tbody>
            ${items
              .map((item) => {
                const name = item.name || item.nama_produk || 'Unknown Product';
                const quantity = item.quantity || item.jumlah || 1;
                const price = item.price || item.harga || 0;
                const subtotal = quantity * price;

                return `
                <tr>
                  <td>${name}</td>
                  <td class="text-center">${quantity}</td>
                  <td class="text-end">Rp${price.toLocaleString('id-ID')}</td>
                  <td class="text-end">Rp${subtotal.toLocaleString(
                    'id-ID'
                  )}</td>
                </tr>
              `;
              })
              .join('')}
          </tbody>
          <tfoot class="table-light">
            <tr>
              <td colspan="3" class="text-end fw-bold">Total:</td>
              <td class="text-end fw-bold">Rp${
                transaction.gross_amount
                  ? transaction.gross_amount.toLocaleString('id-ID')
                  : '0'
              }</td>
            </tr>
          </tfoot>
        </table>
      </div>
    `;
  } catch (error) {
    console.error('Error rendering item details:', error);
    container.innerHTML = `
      <div class="alert alert-danger">
        <h5>Gagal Memuat Detail Item</h5>
        <p>${error.message}</p>
      </div>
    `;
  }
}

function addActionButtons(status, orderId) {
  const container = document.getElementById('actionButtons');

  // Hanya tampilkan tombol untuk transaksi pending
  if (status === 'pending') {
    container.innerHTML = `
      <div class="card mt-4">
        <div class="card-header bg-light">
          <h5 class="card-title mb-0">Tindakan Admin</h5>
        </div>
        <div class="card-body">
          <div class="d-flex gap-2 flex-wrap">
            <button class="btn btn-success" onclick="approveTransaction('${orderId}')">
              <i class="fas fa-check me-2"></i>Setujui Transaksi
            </button>
            <button class="btn btn-danger" onclick="rejectTransaction('${orderId}')">
              <i class="fas fa-times me-2"></i>Tolak Transaksi
            </button>
            <button class="btn btn-warning" onclick="addAdminNotes('${orderId}')">
              <i class="fas fa-edit me-2"></i>Tambah Catatan
            </button>
          </div>
        </div>
      </div>
    `;
  } else {
    container.innerHTML = '';
  }
}

function getStatusLabel(status) {
  const statusLabels = {
    pending: 'Menunggu Pembayaran',
    settlement: 'Sukses',
    capture: 'Tertangkap',
    deny: 'Ditolak',
    cancel: 'Dibatalkan',
    expire: 'Kadaluarsa',
    refund: 'Dikembalikan',
  };
  return statusLabels[status] || status;
}

// Fungsi untuk menangani persetujuan transaksi
window.approveTransaction = async function (orderId) {
  try {
    if (!confirm('Apakah Anda yakin ingin menyetujui transaksi ini?')) return;

    const token = Auth.getToken();
    const response = await fetch(`/api/transactions/${orderId}/status`, {
      method: 'PUT',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ status: 'settlement' }),
    });

    // Handle token expired
    if (response.status === 401) {
      showAlert('danger', 'Sesi telah berakhir. Silakan login kembali.');
      setTimeout(() => {
        Auth.logout();
        window.location.href = '/admin/login';
      }, 2000);
      return;
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || 'Gagal menyetujui transaksi');
    }

    showAlert('success', 'Transaksi berhasil disetujui');
    setTimeout(() => {
      window.location.reload();
    }, 1500);
  } catch (error) {
    console.error('Error approving transaction:', error);
    showAlert('danger', 'Gagal menyetujui transaksi: ' + error.message);
  }
};

// Fungsi untuk menangani penolakan transaksi
window.rejectTransaction = async function (orderId) {
  try {
    if (!confirm('Apakah Anda yakin ingin menolak transaksi ini?')) return;

    const token = Auth.getToken();
    const response = await fetch(`/api/transactions/${orderId}/status`, {
      method: 'PUT',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ status: 'deny' }),
    });

    // Handle token expired
    if (response.status === 401) {
      showAlert('danger', 'Sesi telah berakhir. Silakan login kembali.');
      setTimeout(() => {
        Auth.logout();
        window.location.href = '/admin/login';
      }, 2000);
      return;
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || 'Gagal menolak transaksi');
    }

    showAlert('success', 'Transaksi berhasil ditolak');
    setTimeout(() => {
      window.location.reload();
    }, 1500);
  } catch (error) {
    console.error('Error rejecting transaction:', error);
    showAlert('danger', 'Gagal menolak transaksi: ' + error.message);
  }
};

// Fungsi untuk menambah catatan admin
window.addAdminNotes = async function (orderId) {
  const notes = prompt('Masukkan catatan admin:');
  if (notes === null) return;

  try {
    const token = Auth.getToken();
    const response = await fetch(`/api/transactions/${orderId}/notes`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ notes }),
    });

    // Handle token expired
    if (response.status === 401) {
      showAlert('danger', 'Sesi telah berakhir. Silakan login kembali.');
      setTimeout(() => {
        Auth.logout();
        window.location.href = '/admin/login';
      }, 2000);
      return;
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || 'Gagal menambah catatan');
    }

    showAlert('success', 'Catatan berhasil ditambahkan');
    setTimeout(() => {
      window.location.reload();
    }, 1500);
  } catch (error) {
    console.error('Error adding admin notes:', error);
    showAlert('danger', 'Gagal menambah catatan: ' + error.message);
  }
};
