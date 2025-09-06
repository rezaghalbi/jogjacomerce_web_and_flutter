import 'package:flutter/foundation.dart';
import 'package:ecomerce_jogja_app/services/product_service.dart';
import 'package:ecomerce_jogja_app/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<ProductCategory> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  int? _selectedCategoryId;
  String _sortBy =
      'newest'; // newest, price_asc, price_desc, name_asc, name_desc

  List<Product> get products => _filteredProducts;
  List<ProductCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  String get sortBy => _sortBy;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _productService.getProducts();
      if (response['success']) {
        List<Product> products = (response['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
        _products = products;
        _applyFilters();
      } else {
        _errorMessage = response['message'] ?? 'Failed to load products';
      }
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await _productService.getCategories();
      if (response['success']) {
        List<ProductCategory> categories = (response['data'] as List)
            .map((item) => ProductCategory.fromJson(item))
            .toList();
        _categories = categories;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  void sortProducts(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void _applyFilters() {
    // Apply search and category filters
    List<Product> filtered = _products.where((product) {
      // Filter by search query
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.namaProduk.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          product.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by category
      final matchesCategory =
          _selectedCategoryId == null ||
          product.categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.harga.compareTo(b.harga));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.harga.compareTo(a.harga));
        break;
      case 'name_asc':
        filtered.sort((a, b) => a.namaProduk.compareTo(b.namaProduk));
        break;
      case 'name_desc':
        filtered.sort((a, b) => b.namaProduk.compareTo(a.namaProduk));
        break;
      case 'newest':
      default:
        // Keep original order (newest first based on creation date)
        if (filtered.isNotEmpty && filtered[0].createdAt != null) {
          filtered.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        }
        break;
    }

    _filteredProducts = filtered;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _sortBy = 'newest';
    _applyFilters();
    notifyListeners();
  }

  Future<Product?> getProductById(int productId) async {
    try {
      final response = await _productService.getProductById(productId);
      if (response['success']) {
        return Product.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Failed to get product: $e');
      return null;
    }
  }
}
