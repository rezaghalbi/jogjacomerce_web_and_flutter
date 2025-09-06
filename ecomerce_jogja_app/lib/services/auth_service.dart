import 'dart:convert';
import 'package:ecomerce_jogja_app/utils/constants.dart';
import 'package:ecomerce_jogja_app/models/user_model.dart';
import 'package:ecomerce_jogja_app/utils/helpers.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await ApiService.postRequest(AppConstants.loginUrl, {
      'username': username,
      'password': password,
    });

    if (response['success']) {
      final token = response['data']['token'];
      final userId = _getUserIdFromToken(token);

      final tempUser = User(userId: userId, username: username, token: token);

      return {'success': true, 'data': tempUser};
    } else {
      return response;
    }
  }

  static String _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return '';
      }

      final payload = parts[1];
      String normalizedPayload = normalizeBase64(payload);
      String decodedPayload = utf8.decode(base64.decode(normalizedPayload));
      final payloadMap = json.decode(decodedPayload);

      return payloadMap['userId']?.toString() ?? '';
    } catch (e) {
      print('Error decoding token: $e');
      return '';
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await ApiService.getRequest(
      AppConstants.profileUrl,
      token: token,
    );

    if (response['success']) {
      return {'success': true, 'data': response['data']};
    } else {
      return response;
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> profileData,
  ) async {
    final response = await ApiService.putRequest(
      AppConstants.profileUrl,
      profileData,
      token: token,
    );

    return response;
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String password,
    String namaLengkap,
    String email,
    String noTelepon,
    String alamat,
  ) async {
    final response = await ApiService.postRequest(AppConstants.registerUrl, {
      'username': username,
      'password': password,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
    });

    return response;
  }
}
