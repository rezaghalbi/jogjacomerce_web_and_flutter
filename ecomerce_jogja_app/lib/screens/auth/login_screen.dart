import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecomerce_jogja_app/providers/auth_provider.dart';
import 'package:ecomerce_jogja_app/utils/constants.dart';
import 'package:ecomerce_jogja_app/widgets/custom_textfield.dart';
import 'package:ecomerce_jogja_app/screens/auth/register_screen.dart';
import 'package:ecomerce_jogja_app/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                // Di bagian logo, tambahkan errorBuilder
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 300,
                    width: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.shopping_cart,
                        size: 100,
                        color: AppConstants.primaryColor,
                      );
                    },
                  ),
                ),
                // SizedBox(height: 20),
                // Center(
                //   child: Text(
                //     'I-COMMERCE',
                //     style: GoogleFonts.poppins(
                //       fontSize: 32,
                //       fontWeight: FontWeight.bold,
                //       color: AppConstants.primaryColor,
                //     ),
                //   ),
                // ),
                // Center(
                //   child: Text(
                //     'YOGYAKARTA',
                //     style: GoogleFonts.poppins(
                //       fontSize: 20,
                //       fontWeight: FontWeight.w500,
                //       color: AppConstants.textColor,
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                Text(
                  'Selamat datang kembali',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Masuk ke akun Anda menggunakan username dan password',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppConstants.greyColor,
                  ),
                ),
                SizedBox(height: 24),
                CustomTextField(
                  controller: _usernameController,
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: AppConstants.greyColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock, color: AppConstants.greyColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    }
                    return null;
                  },
                ),
                // SizedBox(height: 8),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {
                //       // TODO: Implement forgot password
                //     },
                //     child: Text(
                //       'Lupa kata sandi?',
                //       style: GoogleFonts.poppins(
                //         color: AppConstants.primaryColor,
                //         fontSize: 14,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 24),
                authProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await authProvider.login(
                                _usernameController.text,
                                _passwordController.text,
                              );

                              if (authProvider.isAuthenticated) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                        ),
                      ),
                // SizedBox(height: 24),
                // Center(
                //   child: Text(
                //     'Atau masuk dengan',
                //     style: GoogleFonts.poppins(
                //       color: AppConstants.greyColor,
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
                // SizedBox(height: 16),
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton.icon(
                //     onPressed: () {
                //       // TODO: Implement Google sign in
                //     },
                //     icon: Image.asset(
                //       'assets/images/google_icon.png',
                //       width: 24,
                //       height: 24,
                //     ),
                //     label: Text(
                //       'Masuk dengan Google',
                //       style: GoogleFonts.poppins(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     style: OutlinedButton.styleFrom(
                //       backgroundColor: AppConstants.textColor,
                //       padding: EdgeInsets.symmetric(vertical: 12),
                //       side: BorderSide(
                //         color: AppConstants.greyColor.withOpacity(0.3),
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Pertama kali kesini? ',
                        style: GoogleFonts.poppins(
                          color: AppConstants.greyColor,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Mendaftar',
                            style: GoogleFonts.poppins(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
