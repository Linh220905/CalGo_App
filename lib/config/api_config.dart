/// Configuration class for centralizing backend domain and API endpoints.
class ApiConfig {
  static String get defaultDomain {
    return 'https://calgo.tech';
  }

  /// Base API Endpoint URL. Single source of truth for all API calls in mobile app.
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (customUrl.isNotEmpty) return customUrl;
    return '$defaultDomain/api/v1';
  }

  /// Converts API-relative media paths into URLs that Image.network can load.
  /// Absolute URLs (including data URLs used by legacy records) are preserved.
  static String? resolveMediaUrl(Object? value) {
    final url = value?.toString().trim();
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) return url;

    final baseUri = Uri.parse(baseUrl);
    if (url.startsWith('/')) {
      return baseUri.replace(path: url, query: null, fragment: null).toString();
    }
    return baseUri.resolve(url).toString();
  }

  static const Duration timeout = Duration(seconds: 30);
  static const Duration refreshThreshold = Duration(minutes: 5);
}
