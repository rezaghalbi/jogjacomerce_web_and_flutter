import { loadHeader } from './admin-common.js';

document.addEventListener('DOMContentLoaded', async () => {
  if (!Auth.isAuthenticated()) {
    window.location.href = '/admin/login';
    return;
  }

  await loadHeader();
  await loadTransactions();
  setupEventListeners();
});

async function loadTransactions() {
  try {
    const token = Auth.getToken();
    const search = document.getElementById('searchInput').value;
    const status = document.getElementById('statusFilter').value;
    const sort = document.getElementById('sortSelect').value;

    // Build URL dengan parameter query
    const params = new URLSearchParams();
    if (search) params.append('search', search);
    if (status && status !== 'all') params.append('status', status);
    if (sort) params.append('sort', sort);

    const url = `/api/transactions/admin?${params.toString()}`;

    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || 'Gagal memuat transaksi');
    }

    const data = await response.json();
    console.log('Data transaksi:', data);

    // Handle berbagai format response
    const transactions = data.data || data.transactions || data;
    renderTransactions(transactions);
  } catch (error) {
    console.error('Error loading transactions:', error);
    showAlert('danger', error.message || 'Gagal memuat data transaksi');
  }
}

function renderTransactions(transactions) {
  const tbody = document.getElementById('transactionsTableBody');

  if (!transactions || transactions.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="7" class="text-center py-4">
          <i class="fas fa-inbox fs-1 text-muted mb-2"></i>
          <p class="text-muted">Tidak ada transaksi ditemukan</p>
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = transactions
    .map((transaction) => {
      const customerName =
        transaction.customer_name ||
        (transaction.user_id ? `User ${transaction.user_id}` : 'Unknown');

      const formattedAmount = transaction.gross_amount
        ? `Rp${transaction.gross_amount.toLocaleString('id-ID')}`
        : 'Rp0';

      const transactionTime = transaction.transaction_time
        ? new Date(transaction.transaction_time).toLocaleString('id-ID')
        : transaction.created_at
        ? new Date(transaction.created_at).toLocaleString('id-ID')
        : '-';

      return `
        <tr>
          <td class="fw-bold">${transaction.order_id || '-'}</td>
          <td>
            <div class="transaction-detail" title="${customerName}">
              ${customerName}
            </div>
          </td>
          <td>${formattedAmount}</td>
          <td>
            <span class="status-badge status-${transaction.payment_status}">
              ${getStatusLabel(transaction.payment_status)}
            </span>
          </td>
          <td>${transaction.payment_method || '-'}</td>
          <td>${transactionTime}</td>
          
        </tr>
      `;
    })
    .join('');

  // Add event listeners to detail buttons
  document.querySelectorAll('.view-detail-btn').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      const orderId = e.currentTarget.getAttribute('data-orderid');
      viewDetail(orderId);
    });
  });
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

function setupEventListeners() {
  // Debounce untuk pencarian
  document
    .getElementById('searchInput')
    .addEventListener('input', debounce(loadTransactions, 300));
  document
    .getElementById('statusFilter')
    .addEventListener('change', loadTransactions);
  document
    .getElementById('sortSelect')
    .addEventListener('change', loadTransactions);

  // Refresh button
  document
    .getElementById('refreshBtn')
    ?.addEventListener('click', loadTransactions);
}

function viewDetail(orderId) {
  window.location.href = `/admin/transaction-detail.html?orderId=${orderId}`;
}

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

// Export functions if needed
window.loadTransactions = loadTransactions;
window.viewDetail = viewDetail;
