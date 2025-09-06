import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecomerce_jogja_app/providers/transaction_provider.dart';
import 'package:ecomerce_jogja_app/utils/constants.dart';
import 'package:ecomerce_jogja_app/models/transaction_model.dart';
import 'package:ecomerce_jogja_app/screens/transaction_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedStatus = 'all';
  String _selectedSort = 'terbaru';
  String _selectedPaymentMethod = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).loadUserTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          _buildFilterSection(transactionProvider),
          Expanded(child: _buildTransactionList(transactionProvider)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(TransactionProvider transactionProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildDropdown(
              label: "Status",
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'settlement', child: Text('Berhasil')),
                DropdownMenuItem(value: 'cancel', child: Text('Dibatalkan')),
                DropdownMenuItem(value: 'expire', child: Text('Kadaluarsa')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                transactionProvider.loadUserTransactions(
                  status: _selectedStatus,
                  sort: _selectedSort,
                  paymentMethod: _selectedPaymentMethod,
                );
              },
            ),
            _buildDropdown(
              label: "Urutkan",
              value: _selectedSort,
              items: const [
                DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')),
                DropdownMenuItem(value: 'terlama', child: Text('Terlama')),
              ],
              onChanged: (value) {
                setState(() => _selectedSort = value!);
                transactionProvider.loadUserTransactions(
                  status: _selectedStatus,
                  sort: _selectedSort,
                  paymentMethod: _selectedPaymentMethod,
                );
              },
            ),
            _buildDropdown(
              label: "Pembayaran",
              value: _selectedPaymentMethod,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua')),
                DropdownMenuItem(
                  value: 'bank_transfer',
                  child: Text('Transfer Bank'),
                ),
                DropdownMenuItem(value: 'gopay', child: Text('Gopay')),
                DropdownMenuItem(value: 'shopeepay', child: Text('ShopeePay')),
                DropdownMenuItem(value: 'qris', child: Text('QRIS')),
              ],
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value!);
                transactionProvider.loadUserTransactions(
                  status: _selectedStatus,
                  sort: _selectedSort,
                  paymentMethod: _selectedPaymentMethod,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(TransactionProvider transactionProvider) {
    if (transactionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactionProvider.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                transactionProvider.errorMessage,
                style: GoogleFonts.poppins(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => transactionProvider.loadUserTransactions(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (transactionProvider.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 80, color: AppConstants.greyColor),
              const SizedBox(height: 16),
              Text(
                'Belum ada transaksi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: AppConstants.greyColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transaksi Anda akan muncul di sini',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppConstants.greyColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactionProvider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactionProvider.transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID
              Text(
                'Order #${transaction.orderId}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              // Status (pindah ke bawah order id)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.paymentStatus),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(transaction.paymentStatus),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Transaction Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Rp ${transaction.grossAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tanggal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatDate(transaction.transactionTime),
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Payment Method
              Text(
                'Metode: ${_getPaymentMethodText(transaction.paymentMethod)}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Lihat Detail →',
                  style: GoogleFonts.poppins(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'settlement':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancel':
      case 'expire':
        return Colors.red;
      case 'deny':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'settlement':
        return 'Berhasil';
      case 'pending':
        return 'Pending';
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
