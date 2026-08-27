import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../services/scan_service.dart';

enum ScanTaskStatus { analyzing, failed, completed }

class ScanTask {
  ScanTask({
    required this.imagePath,
    required this.authScope,
    required this.payload,
    this.languageCode,
  }) : id = DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String imagePath;
  final int authScope;
  final String payload;
  final String? languageCode;
  ScanTaskStatus status = ScanTaskStatus.analyzing;
  int progress = 6;
  String? resultId;
  int expEarned = 0;
  String? errorMessage;
  int? errorStatusCode;
  String? errorDetail;
  bool _unrecognizedFoodAlertHandled = false;

  bool get isUnrecognizedFood =>
      errorStatusCode == 422 &&
      (errorDetail ?? '').toLowerCase().contains('chưa phân tích rõ món ăn');

  /// Returns true only once for each failed scan attempt so rebuilding Home
  /// after a tab change cannot reopen an alert the user already dismissed.
  bool takeUnrecognizedFoodAlert() {
    if (!isUnrecognizedFood || _unrecognizedFoodAlertHandled) return false;
    _unrecognizedFoodAlertHandled = true;
    return true;
  }

  void resetUnrecognizedFoodAlert() {
    _unrecognizedFoodAlertHandled = false;
  }
}

/// Keeps one scan alive while the camera page is closed.  It intentionally
/// owns no UI/navigation: Home displays the card and MainShell opens Result.
class ScanTaskProvider extends ChangeNotifier {
  ScanTaskProvider(this._scanService);

  final ScanService _scanService;
  ScanTask? _task;
  Timer? _progressTimer;

  ScanTask? get task => _task;
  bool get isAnalyzing => _task?.status == ScanTaskStatus.analyzing;
  ScanTask? get completedTask =>
      _task?.status == ScanTaskStatus.completed ? _task : null;

  bool startScan({
    required String imagePath,
    required String base64Image,
    String? languageCode,
  }) {
    if (isAnalyzing) return false;
    final task = ScanTask(
      imagePath: imagePath,
      authScope: _scanService.authScope,
      payload: base64Image,
      languageCode: languageCode,
    );
    _task = task;
    _startProgress(task);
    notifyListeners();
    unawaited(_run(task));
    return true;
  }

  void retry() {
    final task = _task;
    if (task == null || task.status != ScanTaskStatus.failed) return;
    if (task.authScope != _scanService.authScope) {
      _task = null;
      notifyListeners();
      return;
    }
    task.status = ScanTaskStatus.analyzing;
    task.progress = 6;
    task.errorMessage = null;
    task.errorStatusCode = null;
    task.errorDetail = null;
    task.resetUnrecognizedFoodAlert();
    _startProgress(task);
    notifyListeners();
    unawaited(_run(task));
  }

  void consumeCompleted(String taskId) {
    if (_task?.id != taskId || _task?.status != ScanTaskStatus.completed) {
      return;
    }
    _task = null;
    _progressTimer?.cancel();
    notifyListeners();
  }

  Future<void> _run(ScanTask task) async {
    try {
      final result = await _scanService.scanMeal(
        task.payload,
        languageCode: task.languageCode,
      );
      if (!identical(_task, task) || task.authScope != _scanService.authScope) {
        if (identical(_task, task)) {
          _task = null;
          notifyListeners();
        }
        return;
      }
      task.status = ScanTaskStatus.completed;
      task.progress = 100;
      task.resultId = result.id;
      task.expEarned = result.expEarned;
    } on ApiException catch (error) {
      if (!identical(_task, task) || task.authScope != _scanService.authScope) {
        return;
      }
      task.status = ScanTaskStatus.failed;
      task.errorStatusCode = error.statusCode;
      task.errorDetail = error.message;
      task.errorMessage = _friendlyError(error);
      debugPrint(
        'Scan request failed: HTTP ${error.statusCode}; detail=${error.message}',
      );
    } catch (error) {
      if (!identical(_task, task) || task.authScope != _scanService.authScope) {
        return;
      }
      task.status = ScanTaskStatus.failed;
      task.errorMessage = _friendlyError(error);
      debugPrint('Scan request failed: ${error.runtimeType}');
    }
    _progressTimer?.cancel();
    notifyListeners();
  }

  void _startProgress(ScanTask task) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 550), (_) {
      if (!identical(_task, task) || task.status != ScanTaskStatus.analyzing) {
        _progressTimer?.cancel();
        return;
      }
      // Vertex does not stream a numeric progress value. Keep this below 100;
      // completion is shown only after the API response is received.
      final increment = task.progress < 45
          ? 7
          : task.progress < 75
              ? 4
              : 1;
      task.progress = (task.progress + increment).clamp(0, 94);
      notifyListeners();
    });
  }

  String _friendlyError(Object error) {
    final value = error.toString().toLowerCase();
    final statusCode = error is ApiException ? error.statusCode : null;
    final detail = error is ApiException ? error.message.toLowerCase() : value;
    if (value.contains('insufficient_credits') || value.contains('402')) {
      return 'scanCreditsExhausted';
    }
    if (statusCode == 422 && detail.contains('chưa phân tích rõ món ăn')) {
      return 'scanUnrecognizedFood';
    }
    if (value.contains('timeout') ||
        value.contains('socketexception') ||
        value.contains('connection')) {
      return 'networkRetry';
    }
    return 'scanUnavailable';
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}
