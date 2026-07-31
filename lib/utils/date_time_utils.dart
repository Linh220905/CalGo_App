/// Parses timestamps returned by the API and converts them to device local time.
///
/// PostgreSQL/FastAPI may serialize UTC timestamps either with an explicit
/// offset (`Z`, `+00:00`) or without one. A timestamp without an offset is
/// treated as UTC because all server-side scan timestamps are stored in UTC.
DateTime? parseApiDateTime(Object? value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return null;

  final hasTimeZone =
      raw.endsWith('Z') || RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(raw);
  final parsed = DateTime.tryParse(hasTimeZone ? raw : '${raw}Z');
  return parsed?.toLocal();
}

String apiDateTimeToLocalIso(Object? value) {
  return parseApiDateTime(value)?.toIso8601String() ??
      DateTime.now().toIso8601String();
}
