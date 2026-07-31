import '../models/scan_result.dart';
import '../models/history_item.dart';
import 'api_service.dart';

class ScanService {
  final ApiService _api;
  final Map<String, List<HistoryItem>> _historyCache = {};
  DateTime? _historyCacheTime;

  ScanService(this._api);

  Future<ScanResult> scanMeal(String base64Image) async {
    final res = await _api.post('/scan', body: {
      'image_base64': base64Image,
    });
    _historyCache.clear();
    _historyCacheTime = null;
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
            const Duration(seconds: 30);
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
    return List<HistoryItem>.of(items);
  }

  Future<ScanResult> getScanDetail(String id) async {
    final res = await _api.get('/scan/$id');
    return ScanResult.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteScan(String id) async {
    await _api.delete('/scan/$id');
    _historyCache.clear();
    _historyCacheTime = null;
  }
}
