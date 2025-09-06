import 'package:flutter/foundation.dart';
import 'package:ecomerce_jogja_app/services/auth_service.dart';
import 'package:ecomerce_jogja_app/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    autoLogin();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await AuthService.login(username, password);

    _isLoading = false;

    if (response['success']) {
      _user = response['data'] as User;

      final profileResponse = await AuthService.getUserProfile(_user!.token);

      if (profileResponse['success']) {
        final userData = profileResponse['data'];
        _user = _user!.copyWith(
          username: userData['username'],
          namaLengkap: userData['nama_lengkap'],
          email: userData['email'],
          noTelepon: userData['no_telepon'],
          alamat: userData['alamat'],
        );
      }

      await _storage.write(key: 'auth_token', value: _user!.token);
      await _storage.write(
        key: 'user_data',
        value: json.encode(_user!.toJson()),
      );

      _errorMessage = '';
    } else {
      _user = null;
      _errorMessage = response['message'] ?? 'Login failed';
    }

    notifyListeners();
  }

  Future<void> register(
    String username,
    String password,
    String namaLengkap,
    String email,
    String noTelepon,
    String alamat,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await AuthService.register(
      username,
      password,
      namaLengkap,
      email,
      noTelepon,
      alamat,
    );

    _isLoading = false;

    if (response['success']) {
      _errorMessage = '';
    } else {
      _errorMessage = response['message'] ?? 'Registration failed';
    }

    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await AuthService.updateProfile(
        _user!.token,
        profileData,
      );

      _isLoading = false;

      if (response['success']) {
        _user = _user!.copyWith(
          username: profileData['username'] ?? _user!.username,
          namaLengkap: profileData['nama_lengkap'] ?? _user!.namaLengkap,
          email: profileData['email'] ?? _user!.email,
          noTelepon: profileData['no_telepon'] ?? _user!.noTelepon,
          alamat: profileData['alamat'] ?? _user!.alamat,
        );

        await _storage.write(
          key: 'user_data',
          value: json.encode(_user!.toJson()),
        );

        _errorMessage = '';
      } else {
        _errorMessage = response['message'] ?? 'Update profile failed';
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Update profile failed: $e';
    }

    notifyListeners();
  }

  Future<void> autoLogin() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final userDataString = await _storage.read(key: 'user_data');

      if (token != null && userDataString != null) {
        final userData = json.decode(userDataString);
        userData['token'] = token;
        _user = User.fromJson(userData);
      }
    } catch (e) {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _isLoading = false;
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }
}
