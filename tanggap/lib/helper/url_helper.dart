
class UrlHelper {
  static const String baseUrl = "https://tanggap.ethiodeploy.app";

  // Membuat URL endpoint API Laravel.
  static String api(String path) {
    final clean = path.startsWith('/')
        ? path.substring(1)
        : path;

    return "$baseUrl/$clean";
  }

  // Mengolah URL gambar.
  // URL Supabase yang sudah lengkap harus dipertahankan.
  static String getFullUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return "";
    }

    String clean = path.trim().replaceAll('\\/', '/');

    // Jika sudah berupa URL HTTPS/HTTP, gunakan langsung.
    if (clean.startsWith('https://') ||
        clean.startsWith('http://')) {
      return clean;
    }

    // Mendukung path lama dari Laravel.
    if (clean.startsWith('/storage/')) {
      return "$baseUrl$clean";
    }

    if (clean.startsWith('storage/')) {
      return "$baseUrl/$clean";
    }

    // Menghapus slash di awal.
    clean = clean.replaceFirst(RegExp(r'^/+'), '');

    // Path lama tanpa prefix storage.
    return "$baseUrl/storage/$clean";
  }
}
