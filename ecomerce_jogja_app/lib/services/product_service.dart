import 'package:ecomerce_jogja_app/utils/constants.dart';
import 'package:ecomerce_jogja_app/services/api_service.dart';

class ProductService {
  Future<Map<String, dynamic>> getProducts() async {
    return await ApiService.getRequest(AppConstants.productsUrl);
  }

  Future<Map<String, dynamic>> getProductById(int productId) async {
    return await ApiService.getRequest(
      '${AppConstants.productsUrl}/$productId',
    );
  }

  Future<Map<String, dynamic>> getCategories() async {
    return await ApiService.getRequest(
      '${AppConstants.productsUrl}/categories',
    );
  }

  Future<Map<String, dynamic>> getProductsByCategory(int categoryId) async {
    return await ApiService.getRequest(
      '${AppConstants.productsUrl}/category/$categoryId',
    );
  }

  Future<Map<String, dynamic>> searchProducts(String keyword) async {
    return await ApiService.getRequest(
      '${AppConstants.productsUrl}/search?keyword=$keyword',
    );
  }
}
