import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/what_to_eat_dish.dart';

/// Fetches the server-hosted 'What To Eat' dish catalog and caches both
/// metadata (in SharedPreferences) and dish photos (in temp disk storage)
/// so the reel stays smooth at 60fps and works offline after first load.
class WhatToEatService {
  WhatToEatService({
    http.Client? client,
    Future<Directory> Function()? cacheDirectoryProvider,
  }) : _client = client ?? http.Client(),
       _cacheDirectoryProvider =
           cacheDirectoryProvider ?? getTemporaryDirectory;

  static WhatToEatService instance = WhatToEatService();

  static const String _prefsKeyPrefix = 'what_to_eat_catalog_v1_';
  static const Duration _catalogTtl = Duration(minutes: 10);
  static const Duration _requestTimeout = Duration(seconds: 8);

  final http.Client _client;
  final Future<Directory> Function() _cacheDirectoryProvider;

  List<WhatToEatDish>? _memoryCatalog;
  String? _memoryLocale;
  DateTime? _lastFetchedAt;
  Future<List<WhatToEatDish>>? _inFlightCatalogFetch;

  final Map<String, File> _memoryImageFiles = {};
  final Map<String, Future<File?>> _inFlightImageDownloads = {};
  Directory? _resolvedImageDir;

  /// Immediate synchronous catalog for zero-flicker initial UI render.
  List<WhatToEatDish> getCachedDishes() {
    return _memoryCatalog ?? WhatToEatDish.fallbackDishes;
  }

  /// Synchronous lookup for an already-cached dish photo on disk.
  File? getCachedImageFileSync(String resolvedUrl) {
    final file = _memoryImageFiles[resolvedUrl];
    if (file != null && file.existsSync()) return file;
    return null;
  }

  /// Loads cached dishes from SharedPreferences if not yet in memory.
  Future<List<WhatToEatDish>> loadPersistedDishes({String locale = 'vi'}) async {
    if (_memoryCatalog != null && _memoryLocale == locale) {
      return _memoryCatalog!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefsKeyPrefix$locale');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final parsed = decoded
              .whereType<Map>()
              .map((m) => WhatToEatDish.fromJson(Map<String, dynamic>.from(m)))
              .where((d) => d.id.isNotEmpty && d.name.isNotEmpty)
              .toList();
          if (parsed.isNotEmpty) {
            _memoryCatalog = parsed;
            _memoryLocale = locale;
            return parsed;
          }
        }
      }
    } catch (_) {
      // Ignore corrupt cache and fall back cleanly.
    }
    return _memoryCatalog ?? WhatToEatDish.fallbackDishes;
  }

  /// Fetches the latest catalog from backend; updates local cache on success.
  Future<List<WhatToEatDish>> fetchDishes({
    String locale = 'vi',
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _memoryCatalog != null &&
        _memoryLocale == locale &&
        _lastFetchedAt != null &&
        now.difference(_lastFetchedAt!) < _catalogTtl) {
      return _memoryCatalog!;
    }

    if (_inFlightCatalogFetch != null && _memoryLocale == locale) {
      return _inFlightCatalogFetch!;
    }

    final future = _doFetchDishes(locale: locale);
    _inFlightCatalogFetch = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightCatalogFetch, future)) {
        _inFlightCatalogFetch = null;
      }
    }
  }

  Future<List<WhatToEatDish>> _doFetchDishes({required String locale}) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/nutrition/what-to-eat',
      ).replace(queryParameters: {'locale': locale});
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final rawList = body is Map ? body['dishes'] : null;
        if (rawList is List) {
          final parsed = rawList
              .whereType<Map>()
              .map((m) => WhatToEatDish.fromJson(Map<String, dynamic>.from(m)))
              .where((d) => d.id.isNotEmpty && d.name.isNotEmpty)
              .toList();
          if (parsed.isNotEmpty) {
            _memoryCatalog = parsed;
            _memoryLocale = locale;
            _lastFetchedAt = DateTime.now();
            await _persistDishes(locale, parsed);
            return parsed;
          }
        }
      }
    } catch (_) {
      // Network unavailable or server unreachable — keep cached/fallback catalog.
    }

    return loadPersistedDishes(locale: locale);
  }

  Future<void> _persistDishes(String locale, List<WhatToEatDish> dishes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(dishes.map((d) => d.toJson()).toList());
      await prefs.setString('$_prefsKeyPrefix$locale', encoded);
    } catch (_) {}
  }

  Future<Directory?> _getImageCacheDir() async {
    if (_resolvedImageDir != null) return _resolvedImageDir;
    try {
      final root = await _cacheDirectoryProvider();
      final dir = Directory('${root.path}/what_to_eat_images');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _resolvedImageDir = dir;
      return dir;
    } catch (_) {
      return null;
    }
  }

  String _cacheFilenameForUrl(String url) {
    final uri = Uri.tryParse(url);
    final rawSegment = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : 'dish.jpg';
    final sanitized = rawSegment.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final hash = url.hashCode.toUnsigned(32).toRadixString(16);
    return '${hash}_$sanitized';
  }

  /// Returns the cached disk [File] for [resolvedUrl], downloading it once if
  /// not yet cached. Returns `null` if unavailable (offline or test env).
  Future<File?> loadImageFile(String resolvedUrl) async {
    if (resolvedUrl.isEmpty) return null;

    final memFile = _memoryImageFiles[resolvedUrl];
    if (memFile != null && await memFile.exists()) {
      return memFile;
    }

    final existingFuture = _inFlightImageDownloads[resolvedUrl];
    if (existingFuture != null) return existingFuture;

    final future = _downloadOrReadImage(resolvedUrl);
    _inFlightImageDownloads[resolvedUrl] = future;
    try {
      return await future;
    } finally {
      _inFlightImageDownloads.remove(resolvedUrl);
    }
  }

  Future<File?> _downloadOrReadImage(String resolvedUrl) async {
    final dir = await _getImageCacheDir();
    if (dir == null) return null;

    final target = File('${dir.path}/${_cacheFilenameForUrl(resolvedUrl)}');
    if (await target.exists() && await target.length() > 0) {
      _memoryImageFiles[resolvedUrl] = target;
      return target;
    }

    try {
      final uri = Uri.tryParse(resolvedUrl);
      if (uri == null || !uri.hasScheme) return null;

      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final tmp = File('${target.path}.tmp');
        await tmp.writeAsBytes(response.bodyBytes, flush: true);
        await tmp.rename(target.path);
        _memoryImageFiles[resolvedUrl] = target;
        return target;
      }
    } catch (_) {
      // Ignore network/disk errors and let UI display fallback placeholder.
    }
    return null;
  }

  /// Warms up disk cache for a list of dishes in the background (best-effort).
  Future<void> prefetchImages(List<WhatToEatDish> dishes) async {
    const batchSize = 4;
    for (var i = 0; i < dishes.length; i += batchSize) {
      final batch = dishes.skip(i).take(batchSize);
      await Future.wait(
        batch.map((d) => loadImageFile(d.resolvedImageUrl)),
      );
    }
  }

  @visibleForTesting
  void clearMemoryCache() {
    _memoryCatalog = null;
    _memoryLocale = null;
    _lastFetchedAt = null;
    _memoryImageFiles.clear();
    _inFlightImageDownloads.clear();
    _resolvedImageDir = null;
  }
}
