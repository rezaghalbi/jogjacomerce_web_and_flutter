// import 'dart:convert';

String normalizeBase64(String base64String) {
  // Tambahkan padding jika diperlukan
  final padding = base64String.length % 4;
  if (padding != 0) {
    return base64String + '=' * (4 - padding);
  }
  return base64String;
}
