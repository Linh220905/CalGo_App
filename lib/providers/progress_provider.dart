import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import '../services/api_service.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _service;
  ProgressStats? _data;
  bool _loading = false;
  bool _mutating = false;
  String? _error;

  ProgressProvider(ApiService api) : _service = ProgressService(api);

  ProgressStats? get data => _data;
  bool get loading => _loading;
  bool get mutating => _mutating;
  String? get error => _error;

  Future<void> refresh({int days = 90}) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.getProgress(days: days);
    } catch (_) {
      _error = 'dataLoadFailed';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> logWeight(double weightKg) async {
    _mutating = true;
    _error = null;
    notifyListeners();
    try {
      await _service.logWeight(weightKg);
      await refresh();
      return true;
    } catch (_) {
      _error = 'saveFailed';
      return false;
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<bool> uploadPhoto(String path) async {
    if (!File(path).existsSync()) return false;
    _mutating = true;
    _error = null;
    notifyListeners();
    try {
      await _service.uploadPhoto(path);
      await refresh();
      return true;
    } catch (_) {
      _error = 'saveFailed';
      return false;
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<bool> deletePhoto(String id) async {
    _mutating = true;
    _error = null;
    notifyListeners();
    try {
      await _service.deletePhoto(id);
      if (_data != null) {
        final next = _data!.progressPhotos
            .where((item) => item.id != id)
            .toList();
        _data = ProgressStats(
          rangeDays: _data!.rangeDays,
          currentWeightKg: _data!.currentWeightKg,
          startWeightKg: _data!.startWeightKg,
          targetWeightKg: _data!.targetWeightKg,
          progressPercent: _data!.progressPercent,
          heightCm: _data!.heightCm,
          bmi: _data!.bmi,
          bmiCategory: _data!.bmiCategory,
          weightHistory: _data!.weightHistory,
          progressPhotos: next,
        );
      }
      return true;
    } catch (_) {
      _error = 'deleteFailed';
      return false;
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }
}
