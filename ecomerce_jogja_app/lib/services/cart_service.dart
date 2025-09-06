import 'package:ecomerce_jogja_app/utils/constants.dart';
import 'package:ecomerce_jogja_app/services/api_service.dart';

class CartService {
  Future<Map<String, dynamic>> getCartItems(String token) async {
    return await ApiService.getRequest(
      '${AppConstants.baseUrl}/api/cart',
      token: token,
    );
  }

  Future<Map<String, dynamic>> updateCartItem(
    int cartId,
    int jumlah,
    String token,
  ) async {
    return await ApiService.putRequest(
      '${AppConstants.baseUrl}/api/cart/$cartId',
      {'jumlah': jumlah},
      token: token,
    );
  }

  Future<Map<String, dynamic>> deleteCartItem(int cartId, String token) async {
    return await ApiService.deleteRequest(
      '${AppConstants.baseUrl}/api/cart/$cartId',
      // {},
      token: token,
    );
  }

  Future<Map<String, dynamic>> checkout(String token) async {
    return await ApiService.postRequest(
      '${AppConstants.baseUrl}/api/cart/checkout',
      {},
      token: token,
    );
  }

  Future<Map<String, dynamic>> addToCart(
    int productId,
    int jumlah,
    String token,
  ) async {
    return await ApiService.postRequest('${AppConstants.baseUrl}/api/cart', {
      'product_id': productId,
      'jumlah': jumlah,
    }, token: token);
  }
}
