
class UrlHelper {
  static const String baseUrl = "https://tanggap.ethiodeploy.app";

  // URL endpoint API.
  static String api(String path) {
    final clean = path.startsWith('/')
        ? path.substring(1)
        : path;

    return "$baseUrl/$clean";
  }

  static String getFullUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    String clean = path.replaceAll('\\/', '/');

    // Menghindari duplikasi /storage/
    if (clean.contains('/storage/')) {
      clean = clean.split('/storage/').last;
    }

    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }

    return "$baseUrl/storage/$clean";
  }
}
