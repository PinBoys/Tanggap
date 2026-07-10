class UrlHelper {
  /// Base URL API/Laravel. Ubah di sini saja saat pindah server.
  static const String baseUrl = "http://10.0.2.2:8000";

  /// Buat URL endpoint API.
  /// Contoh: UrlHelper.api('/api/pengaduan')
  static String api(String path) {
    final clean = (path.startsWith('/') ? path.substring(1) : path);
    return "$baseUrl/$clean";
  }

  static String getFullUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    // 1. Bersihkan escaping slash
    String clean = path.replaceAll('\\/', '/');

    // 2. Bersihkan duplikasi /storage/
    if (clean.contains('/storage/')) {
      clean = clean.split('/storage/').last;
    }

    // Menghilangkan slash di awal jika ada (untuk mencegah double slash)
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }

    return "$baseUrl/storage/$clean";
  }
}