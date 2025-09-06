import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecomerce_jogja_app/models/transaction_model.dart';
import 'package:ecomerce_jogja_app/utils/constants.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: const Color(0xff648286),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Pesanan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Order ID', transaction.orderId),
                    _buildDetailRow(
                      'Tanggal Transaksi',
                      _formatDate(transaction.transactionTime),
                    ),
                    _buildDetailRow(
                      'Status',
                      _getStatusText(transaction.paymentStatus),
                    ),
                    _buildDetailRow(
                      'Metode Pembayaran',
                      _getPaymentMethodText(transaction.paymentMethod),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Total Pembayaran',
                      'Rp ${transaction.grossAmount.toStringAsFixed(0)}',
                      isBold: true,
                      valueColor: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Item Pesanan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...transaction.items
                        .map((item) => _buildItemRow(item))
                        .toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruksi Pembayaran (hanya jika pending)
            if (transaction.paymentStatus == 'pending')
              _buildPaymentInstructions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 👉 TANPA GAMBAR PRODUK
  Widget _buildItemRow(TransactionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detail produk (tanpa gambar)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item.price.toStringAsFixed(0)} x ${item.quantity}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Total harga
          Text(
            'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instruksi Pembayaran',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Silakan selesaikan pembayaran Anda dalam waktu 24 jam',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (transaction.paymentMethod == 'bank_transfer')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('1. Buka aplikasi mobile banking Anda'),
                  Text('2. Pilih menu Transfer'),
                  Text('3. Masukkan kode bank dan nomor virtual account'),
                  Text('4. Konfirmasi pembayaran'),
                ],
              ),
            if (transaction.paymentMethod == 'gopay')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('1. Buka aplikasi Gojek'),
                  Text('2. Pilih menu Bayar'),
                  Text('3. Scan QR code yang tersedia'),
                  Text('4. Konfirmasi pembayaran'),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mengarahkan ke pembayaran...")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Selesaikan Pembayaran',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'settlement':
        return 'Berhasil';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'cancel':
        return 'Dibatalkan';
      case 'expire':
        return 'Kadaluarsa';
      case 'deny':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'gopay':
        return 'Gopay';
      case 'shopeepay':
        return 'ShopeePay';
      case 'qris':
        return 'QRIS';
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
