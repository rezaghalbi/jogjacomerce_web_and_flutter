import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecomerce_jogja_app/providers/auth_provider.dart';
import 'package:ecomerce_jogja_app/providers/cart_provider.dart';
import 'package:ecomerce_jogja_app/providers/transaction_provider.dart';
import 'package:ecomerce_jogja_app/providers/product_provider.dart'; // ✅ tambahkan ini
import 'package:ecomerce_jogja_app/screens/main_screen.dart';
import 'package:ecomerce_jogja_app/screens/auth/login_screen.dart';
import 'package:ecomerce_jogja_app/screens/account_screen.dart';
import 'package:ecomerce_jogja_app/screens/edit_profile_screen.dart';
import 'package:ecomerce_jogja_app/screens/history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()), // ✅ fix
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(),
        ), // ✅ fix
      ],
      child: MaterialApp(
        title: 'E-Commerce Jogja',
        theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Poppins'),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authProvider.isAuthenticated
                ? const MainScreen()
                : const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
          '/account': (context) => const AccountScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/history': (context) => const TransactionHistoryScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
