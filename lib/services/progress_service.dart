import '../models/progress.dart';
import 'api_service.dart';

class ProgressService {
  final ApiService _api;

  ProgressService(this._api);

  Future<ProgressStats> getProgress({int days = 90}) async {
    final response = await _api.get('/stats/progress?days=$days');
    return ProgressStats.fromJson(response as Map<String, dynamic>);
  }

  Future<void> logWeight(double weightKg, {DateTime? date}) async {
    await _api.post(
      '/stats/weight',
      body: {
        'weight_kg': weightKg,
        if (date != null) 'logged_date': _dateKey(date),
      },
    );
  }

  Future<ProgressPhoto> uploadPhoto(String path, {DateTime? date}) async {
    final response = await _api.postMultipart(
      '/stats/progress-photos',
      fieldName: 'image',
      filePath: path,
      fields: {'captured_date': _dateKey(date ?? DateTime.now())},
    );
    return ProgressPhoto.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deletePhoto(String id) =>
      _api.delete('/stats/progress-photos/$id');

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
