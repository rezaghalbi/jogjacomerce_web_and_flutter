import 'package:flutter/material.dart';
import 'package:ecomerce_jogja_app/screens/dashboard_screen.dart';
import 'package:ecomerce_jogja_app/screens/cart_screen.dart';
import 'package:ecomerce_jogja_app/screens/history_screen.dart';
import 'package:ecomerce_jogja_app/screens/account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 👉 Warna utama (bisa diganti sesuai kebutuhan)
  static const Color primaryColor = Color(0xFF648286); // hijau-abu
  static const Color backgroundColor = Color(0xFFF5F5F5); // abu muda

  final List<Widget> _screens = [
    DashboardScreen(),
    CartScreen(),
    TransactionHistoryScreen(),
    AccountScreen(),
  ];

  final List<String> _appBarTitles = [
    'Dashboard',
    'Keranjang Belanja',
    'Riwayat Transaksi',
    'Pengaturan Akun',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _appBarTitles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // teks & icon di AppBar putih
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 208, 208, 208),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,

        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}
