import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ecomerce_jogja_app/services/cart_service.dart';
import 'package:ecomerce_jogja_app/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Track loading states per cartId
  final Map<int, bool> _updating = {};

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<int, bool> get updatingMap => _updating;

  double get totalPrice => _cartItems.fold<double>(
    0.0,
    (sum, item) => sum + (item.harga * item.jumlah),
  );

  Future<String?> _getToken() async => await _storage.read(key: 'auth_token');

  // --- Load cart ---
  Future<void> loadCartItems() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Silakan login terlebih dahulu';
        return;
      }

      final response = await _cartService.getCartItems(token);

      if (response is Map && response['success'] == true) {
        final raw = response['data'];
        if (raw is List) {
          _cartItems = raw.map<CartItem>((e) {
            if (e is Map<String, dynamic>) return CartItem.fromJson(e);
            return CartItem.fromJson(Map<String, dynamic>.from(e));
          }).toList();
        } else {
          _cartItems = [];
          _errorMessage = 'Format data keranjang tidak valid';
        }
      } else {
        _cartItems = [];
        _errorMessage =
            response['message']?.toString() ?? 'Gagal memuat keranjang';
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('loadCartItems error: $e\n$st');
      }
      _errorMessage = 'Gagal memuat keranjang: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Add to cart ---
  Future<void> addToCart(int productId, int jumlah) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Silakan login terlebih dahulu');

      final response = await _cartService.addToCart(productId, jumlah, token);
      if (kDebugMode) print('addToCart response: $response');

      if (response is Map && response['success'] == true) {
        await loadCartItems(); // Reload cart setelah berhasil
      } else {
        final msg =
            response['message']?.toString() ?? 'Gagal menambahkan ke keranjang';
        throw Exception(msg);
      }
    } catch (e) {
      if (kDebugMode) print('addToCart error: $e');
      throw Exception('Gagal menambahkan ke keranjang: $e');
    }
  }

  // --- Update quantity (by cartId) ---
  Future<void> updateItemQuantity(int cartId, int newQuantity) async {
    if (newQuantity < 1) {
      await deleteItem(cartId);
      return;
    }

    _updating[cartId] = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Silakan login terlebih dahulu');

      final response = await _cartService.updateCartItem(
        cartId,
        newQuantity,
        token,
      );
      if (kDebugMode) print('updateCartItem response: $response');

      if (response is Map && response['success'] == true) {
        final idx = _cartItems.indexWhere((c) => c.cartId == cartId);
        if (idx != -1) {
          _cartItems[idx] = _cartItems[idx].copyWith(jumlah: newQuantity);
          notifyListeners();
        } else {
          await loadCartItems(); // Reload jika item tidak ditemukan
        }
      } else {
        final msg =
            response['message']?.toString() ?? 'Gagal memperbarui jumlah';
        throw Exception(msg);
      }
    } catch (e) {
      if (kDebugMode) print('updateItemQuantity error: $e');
      throw Exception('Gagal memperbarui jumlah: $e');
    } finally {
      _updating.remove(cartId);
      notifyListeners();
    }
  }

  // --- Delete item ---
  Future<void> deleteItem(int cartId) async {
    _updating[cartId] = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Silakan login terlebih dahulu');

      final response = await _cartService.deleteCartItem(cartId, token);
      if (kDebugMode) print('deleteCartItem response: $response');

      if (response is Map && response['success'] == true) {
        _cartItems.removeWhere((c) => c.cartId == cartId);
        notifyListeners();
      } else {
        final msg = response['message']?.toString() ?? 'Gagal menghapus item';
        throw Exception(msg);
      }
    } catch (e) {
      if (kDebugMode) print('deleteItem error: $e');
      throw Exception('Gagal menghapus item: $e');
    } finally {
      _updating.remove(cartId);
      notifyListeners();
    }
  }

  // --- Checkout ---
  Future<Map<String, dynamic>> checkout() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Silakan login terlebih dahulu');

      final response = await _cartService.checkout(token);
      if (kDebugMode) print('checkout response: $response');

      if (response is Map && response['success'] == true) {
        _cartItems.clear();
        notifyListeners();
        return {'success': true, 'data': response['data']};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Checkout gagal',
        };
      }
    } catch (e) {
      if (kDebugMode) print('checkout error: $e');
      return {'success': false, 'message': 'Checkout gagal: $e'};
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
