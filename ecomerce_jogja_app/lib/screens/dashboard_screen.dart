import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecomerce_jogja_app/providers/auth_provider.dart';
import 'package:ecomerce_jogja_app/providers/product_provider.dart';
import 'package:ecomerce_jogja_app/models/product_model.dart';
import 'package:ecomerce_jogja_app/utils/constants.dart';
import 'package:ecomerce_jogja_app/screens/product_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFilterOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadProducts();
      productProvider.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchFilterBar(productProvider),
          if (_showFilterOptions) _buildFilterOptions(productProvider),
          Expanded(child: _buildBody(productProvider)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 80,
            width: 50,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.shopping_cart,
                size: 50,
                color: AppConstants.primaryColor,
              );
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'I-COMMERCE YOGYAKARTA',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                Text(
                  'Temukan produk terbaik dengan harga terjangkau',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppConstants.greyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterBar(ProductProvider productProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppConstants.lightGreyColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      productProvider.searchProducts(_searchController.text);
                    },
                  ),
                ),
                onChanged: (value) {
                  productProvider.searchProducts(value);
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _showFilterOptions
                  ? AppConstants.primaryColor
                  : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showFilterOptions = !_showFilterOptions;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(ProductProvider productProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppConstants.lightGreyColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: productProvider.selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Semua Kategori'),
                    ),
                    ...productProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.categoryId,
                        child: Text(category.namaKategori),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    productProvider.filterByCategory(value);
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: productProvider.sortBy,
                  decoration: InputDecoration(
                    labelText: 'Urutkan',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Harga: Rendah ke Tinggi'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Harga: Tinggi ke Rendah'),
                    ),
                    DropdownMenuItem(
                      value: 'name_asc',
                      child: Text('Nama: A-Z'),
                    ),
                    DropdownMenuItem(
                      value: 'name_desc',
                      child: Text('Nama: Z-A'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      productProvider.sortProducts(value);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (productProvider.selectedCategoryId != null ||
              productProvider.searchQuery.isNotEmpty ||
              productProvider.sortBy != 'newest')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  productProvider.clearFilters();
                  _searchController.clear();
                  setState(() {
                    _showFilterOptions = false;
                  });
                },
                child: Text('Reset Filter'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (productProvider.errorMessage.isNotEmpty) {
      return Center(
        child: Text(productProvider.errorMessage, style: GoogleFonts.poppins()),
      );
    }

    return productProvider.products.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: AppConstants.greyColor),
                SizedBox(height: 16),
                Text(
                  'Tidak ada produk ditemukan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppConstants.greyColor,
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    productProvider.clearFilters();
                    _searchController.clear();
                  },
                  child: Text('Reset Filter'),
                ),
              ],
            ),
          )
        : GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(productProvider.products[index]);
            },
          );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppConstants.lightGreyColor,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
              ),
            ),
            // Detail Produk
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.namaProduk,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1, // <-- hanya 1 baris
                      overflow: TextOverflow.ellipsis, // <-- kasih "..."
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rp ${product.harga.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Stok: ${product.stok}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    // if (product.namaKategori != null)
                    //   Text(
                    //     product.namaKategori!,
                    //     style: GoogleFonts.poppins(
                    //       fontSize: 12,
                    //       color: Colors.blue,
                    //     ),
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
