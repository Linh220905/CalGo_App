import 'package:flutter/widgets.dart';
import '../models/scan_result.dart';
import '../models/history_item.dart';
import 'api_service.dart';

class ScanService {
  final ApiService _api;
  final Map<String, List<HistoryItem>> _historyCache = {};
  DateTime? _historyCacheTime;
  int? _historyCacheAuthScope;

  ScanService(this._api);

  int get authScope => _api.authScope;

  Future<ScanResult> scanMeal(String base64Image, {String? languageCode}) async {
    final res = await _api.post('/scan', body: {
      'image_base64': base64Image,
      if (languageCode != null && languageCode.isNotEmpty)
        'app_language': languageCode,
    });
    _historyCache.clear();
    _historyCacheTime = null;
    _historyCacheAuthScope = null;
    return ScanResult.fromJson(res as Map<String, dynamic>);
  }

  Future<List<HistoryItem>> getHistory({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$limit:$offset';
    final cacheFresh = _historyCacheTime != null &&
        DateTime.now().difference(_historyCacheTime!) <
            const Duration(minutes: 5) &&
        _historyCacheAuthScope == _api.authScope;
    if (!forceRefresh && cacheFresh && _historyCache.containsKey(cacheKey)) {
      return List<HistoryItem>.of(_historyCache[cacheKey]!);
    }

    final res = await _api.get('/scan/history?limit=$limit&offset=$offset');
    if (res is! List) return [];
    final items = res
        .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    _historyCache[cacheKey] = items;
    _historyCacheTime = DateTime.now();
    _historyCacheAuthScope = _api.authScope;
    return List<HistoryItem>.of(items);
  }

  Future<List<HistoryItem>> getAllHistory({bool forceRefresh = false}) async {
    const pageSize = 100;
    var offset = 0;
    final items = <HistoryItem>[];
    while (true) {
      final page = await getHistory(
        limit: pageSize,
        offset: offset,
        forceRefresh: forceRefresh,
      );
      items.addAll(page);
      if (page.length < pageSize) break;
      offset += page.length;
    }
    return items;
  }

  /// Pre-fetches metadata for recent meals (24 items) after Home loads,
  /// and precaches only the first 6-12 thumbnails to avoid heavy network/RAM usage.
  Future<void> preloadHistoryImages(BuildContext context, {int limit = 24, int precacheCount = 12}) async {
    try {
      final items = await getHistory(limit: limit, offset: 0);
      if (!context.mounted) return;
      precacheItems(context, items.take(precacheCount).toList());
    } catch (_) {}
  }

  /// Precaches thumbnails for a specific list of items (used when scrolling / loading pages).
  void precacheItems(BuildContext context, List<HistoryItem> items) {
    if (!context.mounted) return;
    for (final item in items) {
      final url = item.thumbnailUrl ?? item.imageUrl;
      if (url != null && url.isNotEmpty) {
        try {
          precacheImage(NetworkImage(url), context);
        } catch (_) {}
      }
    }
  }

  Future<ScanResult> getScanDetail(String id) async {
    final res = await _api.get('/scan/$id');
    return ScanResult.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteScan(String id) async {
    await _api.delete('/scan/$id');
    _historyCache.clear();
    _historyCacheTime = null;
    _historyCacheAuthScope = null;
  }
}
