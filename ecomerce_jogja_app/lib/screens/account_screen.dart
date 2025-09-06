import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecomerce_jogja_app/providers/auth_provider.dart';
import 'package:ecomerce_jogja_app/utils/constants.dart';
import 'package:ecomerce_jogja_app/screens/edit_profile_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Akun Saya'),
      //   backgroundColor: const Color(0xff828664),
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.edit),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => EditProfileScreen()),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Akun',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (authProvider.user != null) ...[
                      _buildAccountItem('User ID', authProvider.user!.userId),
                      if (authProvider.user!.username != null)
                        _buildAccountItem(
                          'Username',
                          authProvider.user!.username!,
                        ),
                      if (authProvider.user!.namaLengkap != null)
                        _buildAccountItem(
                          'Nama Lengkap',
                          authProvider.user!.namaLengkap!,
                        ),
                      if (authProvider.user!.email != null)
                        _buildAccountItem('Email', authProvider.user!.email!),
                      if (authProvider.user!.noTelepon != null)
                        _buildAccountItem(
                          'No. Telepon',
                          authProvider.user!.noTelepon!,
                        ),
                      if (authProvider.user!.alamat != null)
                        _buildAccountItem('Alamat', authProvider.user!.alamat!),
                    ] else ...[
                      Center(
                        child: Text(
                          'Data pengguna tidak tersedia',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppConstants.greyColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Pengaturan',
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    // SizedBox(height: 16),
                    // _buildSettingsItem(
                    //   Icons.notifications,
                    //   'Notifikasi',
                    //   () {},
                    // ),
                    // _buildSettingsItem(Icons.lock, 'Keamanan', () {}),
                    // _buildSettingsItem(Icons.help, 'Bantuan', () {}),
                    // _buildSettingsItem(Icons.info, 'Tentang Aplikasi', () {}),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
                child: Text('Edit Profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF648286),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 86, 24, 19),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
