import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

/// Best-effort product analytics. Unauthenticated onboarding events are sent
/// immediately via the anonymous endpoint.
class AnalyticsService {
  static const _pendingKey = 'pending_analytics_events';
  static const _anonymousIdKey = 'analytics_anonymous_id';
  static const _appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.7+49',
  );

  final ApiService _api;
  bool _flushing = false;
  String? _cachedAnonymousId;

  AnalyticsService(this._api);

  Future<String> getAnonymousId() async {
    if (_cachedAnonymousId != null && _cachedAnonymousId!.isNotEmpty) {
      return _cachedAnonymousId!;
    }
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_anonymousIdKey);
    if (id == null || id.isEmpty) {
      final rand = Random.secure();
      final values = List<int>.generate(16, (i) => rand.nextInt(256));
      id = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await prefs.setString(_anonymousIdKey, id);
    }
    _cachedAnonymousId = id;
    return id;
  }

  String get _platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  Future<void> trackAppFirstOpen() => track('app_first_open');

  Future<void> trackOnboardingStarted() => track(
        'onboarding_started',
        source: 'onboarding',
        paywallVersion: 'v1',
      );

  Future<void> trackOnboardingQ5() => track(
        'onboarding_q5',
        source: 'onboarding',
        paywallVersion: 'v1',
      );

  Future<void> trackOnboardingQ10() => track(
        'onboarding_q10',
        source: 'onboarding',
        paywallVersion: 'v1',
      );

  Future<void> trackOnboardingQ15() => track(
        'onboarding_q15',
        source: 'onboarding',
        paywallVersion: 'v1',
      );

  Future<void> trackOnboardingQ20() => track(
        'onboarding_q20',
        source: 'onboarding',
        paywallVersion: 'v1',
      );

  Future<void> trackOnboardingCompleted() => track(
        'onboarding_completed',
        source: 'onboarding',
        paywallVersion: 'v1',
      );

  Future<void> trackAuthScreenView() => track(
        'auth_screen_view',
        source: 'onboarding',
        paywallVersion: 'v1',
      );

  Future<void> trackLoginSuccess({required String method}) => track(
        'login_success',
        source: method,
        paywallVersion: 'v1',
      );

  Future<void> trackPaywallViewed({required String source}) => track(
        'paywall_viewed',
        source: source,
        paywallVersion: 'v1',
      );

  Future<void> trackPremiumPurchased({
    required String source,
    required String productId,
    required String plan,
    double? price,
    String? currency,
  }) =>
      track(
        'premium_purchased',
        source: source,
        paywallVersion: 'v1',
        productId: productId,
        plan: plan,
        price: price,
        currency: currency,
      );

  Future<void> track(
    String eventName, {
    String? source,
    String? paywallVersion,
    String? productId,
    String? plan,
    double? price,
    String? currency,
  }) async {
    final anonymousId = await getAnonymousId();
    final payload = <String, dynamic>{
      'event_name': eventName,
      'anonymous_id': anonymousId,
      'platform': _platform,
      'app_version': _appVersion,
      if (source != null && source.trim().isNotEmpty) 'source': source,
      if (paywallVersion != null) 'paywall_version': paywallVersion,
      if (productId != null) 'product_id': productId,
      if (plan != null) 'plan': plan,
      if (price != null) 'price': price,
      if (currency != null && currency.trim().isNotEmpty) 'currency': currency,
    };

    if (!_api.hasAccessToken) {
      // Send directly to anonymous endpoint so server gets real-time onboarding funnel drop-offs
      try {
        await _api.post('/analytics/anonymous-events', body: payload);
      } catch (error) {
        debugPrint('[Analytics] anonymous $eventName failed: $error');
        await _enqueue(payload);
      }
      return;
    }

    try {
      await _api.post('/analytics/events', body: payload);
    } catch (error) {
      debugPrint('[Analytics] $eventName failed: $error');
      // Do not persist a failed authenticated request: after account
      // switching there would be no safe way to attribute that payload to the
      // original server user. Analytics is intentionally best-effort.
    }
  }

  /// Flushes events recorded by the onboarding paywall before account login.
  Future<void> flushPending() async {
    if (_flushing || !_api.hasAccessToken) return;
    _flushing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_pendingKey) ?? const <String>[];
      if (raw.isEmpty) return;
      final remaining = <String>[];
      for (var index = 0; index < raw.length; index++) {
        final item = raw[index];
        try {
          final payload = jsonDecode(item);
          if (payload is! Map) continue;
          await _api.post(
            '/analytics/events',
            body: Map<String, dynamic>.from(payload),
          );
        } catch (error) {
          debugPrint('[Analytics] queued event failed: $error');
          remaining.addAll(raw.sublist(index));
          break;
        }
      }
      await prefs.setStringList(_pendingKey, remaining);
    } finally {
      _flushing = false;
    }
  }

  Future<void> _enqueue(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingKey) ?? <String>[];
      pending.add(jsonEncode(payload));
      // A bad backend should not create unbounded local storage.
      await prefs.setStringList(
        _pendingKey,
        pending.length > 50 ? pending.sublist(pending.length - 50) : pending,
      );
    } catch (error) {
      debugPrint('[Analytics] queue failed: $error');
    }
  }
}
