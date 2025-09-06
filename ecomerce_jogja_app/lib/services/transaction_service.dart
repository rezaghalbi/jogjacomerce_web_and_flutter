import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecomerce_jogja_app/utils/constants.dart';

class TransactionService {
  final String _baseUrl = AppConstants.baseUrl;

  Future<Map<String, dynamic>> getUserTransactions(
    String token, {
    String status = 'all',
    String sort = 'terbaru',
    String paymentMethod = 'all',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/api/transactions?status=$status&sort=$sort&payment_method=$paymentMethod',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getTransactionDetail(
    String token,
    String orderId,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/api/transactions/$orderId/detail');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ??
              'Request failed with status ${response.statusCode}',
        };
      }
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Invalid JSON response from server: $e',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error processing response: $e'};
    }
  }
}
