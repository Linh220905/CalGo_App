import 'package:intl/intl.dart';

List<String> localizedWeekdays(String languageCode) {
  final sunday = DateTime(2024, 1, 7);
  final formatter = DateFormat.E(languageCode);
  return List.generate(
      7, (index) => formatter.format(sunday.add(Duration(days: index))));
}

String localizedMonth(DateTime date, String languageCode) {
  return DateFormat.MMMM(languageCode).format(date);
}

String localizedShortDate(DateTime date, String languageCode) {
  return DateFormat.Md(languageCode).format(date);
}

String localizedTime(DateTime? date, String languageCode) {
  return DateFormat.jm(languageCode).format(date ?? DateTime(2000, 1, 1, 9));
}
