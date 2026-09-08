import '../models/meal_guidance.dart';
import 'api_service.dart';

class MealGuidanceService {
  final ApiService _api;
  MealGuidance? _cachedGuidance;
  DateTime? _cachedTime;
  int? _cachedAuthScope;
  Future<MealGuidance>? _inFlightRequest;

  static const _cacheDuration = Duration(minutes: 15);

  MealGuidanceService(this._api);

  void invalidateCache() {
    _cachedGuidance = null;
    _cachedTime = null;
    _cachedAuthScope = null;
  }

  Future<MealGuidance> getToday({
    bool generate = false,
    bool refresh = false,
    String locale = 'en',
  }) async {
    final now = DateTime.now();
    final isCacheValid = !refresh &&
        !generate &&
        _cachedGuidance != null &&
        _cachedTime != null &&
        now.difference(_cachedTime!) < _cacheDuration &&
        _cachedAuthScope == _api.authScope;

    if (isCacheValid) {
      return _cachedGuidance!;
    }

    if (_inFlightRequest != null && !refresh && !generate) {
      return await _inFlightRequest!;
    }

    final query = <String>[];
    if (generate) query.add('generate=true');
    if (refresh) query.add('refresh=true');
    if (locale.isNotEmpty) query.add('locale=$locale');
    final queryString = query.isEmpty ? '' : '?${query.join('&')}';

    final requestFuture = () async {
      try {
        final response = await _api.get(
          '/nutrition/meal-guidance/today$queryString',
          caller: 'MealGuidanceService.getToday',
        );
        if (response is! Map<String, dynamic>) {
          throw StateError('Invalid meal guidance response');
        }
        final guidance = MealGuidance.fromJson(response);
        _cachedGuidance = guidance;
        _cachedTime = DateTime.now();
        _cachedAuthScope = _api.authScope;
        return guidance;
      } finally {
        _inFlightRequest = null;
      }
    }();

    _inFlightRequest = requestFuture;
    return await requestFuture;
  }
}

