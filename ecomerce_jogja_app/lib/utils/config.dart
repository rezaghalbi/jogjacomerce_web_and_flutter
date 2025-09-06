import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomerce_jogja_app/utils/constants.dart';

class Config {
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', url);
    AppConstants.baseUrl = url;
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url') ?? AppConstants.baseUrl;
  }

  static Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('base_url');
    if (savedUrl != null) {
      AppConstants.baseUrl = savedUrl;
    }
  }
}
