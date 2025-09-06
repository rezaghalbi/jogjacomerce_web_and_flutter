import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ecomerce_jogja_app/services/transaction_service.dart';
import 'package:ecomerce_jogja_app/models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<String?> _getToken() async => await _storage.read(key: 'auth_token');

  Future<void> loadUserTransactions({
    String status = 'all',
    String sort = 'terbaru',
    String paymentMethod = 'all',
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Silakan login terlebih dahulu';
        return;
      }

      final response = await _transactionService.getUserTransactions(
        token,
        status: status,
        sort: sort,
        paymentMethod: paymentMethod,
      );

      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _transactions = data
              .map<Transaction>((item) => Transaction.fromJson(item))
              .toList();
        } else {
          _transactions = [];
          _errorMessage = 'Format data transaksi tidak valid';
        }
      } else {
        _transactions = [];
        _errorMessage = response['message'] ?? 'Gagal memuat transaksi';
      }
    } catch (e) {
      _transactions = [];
      _errorMessage = 'Gagal memuat transaksi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getTransactionDetail(String orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      final response = await _transactionService.getTransactionDetail(
        token,
        orderId,
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil detail transaksi: $e',
      };
    }
  }
}
