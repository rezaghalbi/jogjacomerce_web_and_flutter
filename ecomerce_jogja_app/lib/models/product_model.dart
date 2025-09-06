class Product {
  final int productId;
  final String namaProduk;
  final String deskripsi;
  final double harga;
  final int stok;
  final String? imageUrl;
  final int? categoryId;
  final String? namaKategori;
  final DateTime? createdAt;

  Product({
    required this.productId,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    this.imageUrl,
    this.categoryId,
    this.namaKategori,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      harga: json['harga'] != null
          ? (json['harga'] is int
                ? (json['harga'] as int).toDouble()
                : json['harga'] is double
                ? json['harga'] as double
                : double.tryParse(json['harga'].toString()) ?? 0.0)
          : 0.0,
      stok: int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString(),
      categoryId: int.tryParse(json['category_id']?.toString() ?? ''),
      namaKategori: json['nama_kategori']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'nama_produk': namaProduk,
      'deskripsi': deskripsi,
      'harga': harga,
      'stok': stok,
      'image_url': imageUrl,
      'category_id': categoryId,
      'nama_kategori': namaKategori,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class ProductCategory {
  final int categoryId;
  final String namaKategori;

  ProductCategory({required this.categoryId, required this.namaKategori});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      namaKategori: json['nama_kategori']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'category_id': categoryId, 'nama_kategori': namaKategori};
  }
}
