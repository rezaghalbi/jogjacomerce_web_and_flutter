class CartItem {
  final int cartId;
  final int productId;
  final String namaProduk;
  final double harga;
  final int jumlah;
  final String? imageUrl;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.namaProduk,
    required this.harga,
    required this.jumlah,
    this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Helper functions untuk parsing
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    return CartItem(
      cartId: parseInt(json['cart_id'] ?? json['cartId'] ?? json['id']),
      productId: parseInt(
        json['product_id'] ?? json['productId'] ?? json['product'],
      ),
      namaProduk: parseString(
        json['nama_produk'] ?? json['namaProduk'] ?? json['name'],
      ),
      harga: parseDouble(json['harga'] ?? json['price'] ?? 0),
      jumlah: parseInt(json['jumlah'] ?? json['quantity'] ?? 0),
      imageUrl: parseString(
        json['image_url'] ?? json['imageUrl'] ?? json['image'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'product_id': productId,
      'nama_produk': namaProduk,
      'harga': harga,
      'jumlah': jumlah,
      'image_url': imageUrl,
    };
  }

  CartItem copyWith({
    int? cartId,
    int? productId,
    String? namaProduk,
    double? harga,
    int? jumlah,
    String? imageUrl,
  }) {
    return CartItem(
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      namaProduk: namaProduk ?? this.namaProduk,
      harga: harga ?? this.harga,
      jumlah: jumlah ?? this.jumlah,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.cartId == cartId &&
        other.productId == productId &&
        other.namaProduk == namaProduk &&
        other.harga == harga &&
        other.jumlah == jumlah &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(cartId, productId, namaProduk, harga, jumlah, imageUrl);
  }
}
