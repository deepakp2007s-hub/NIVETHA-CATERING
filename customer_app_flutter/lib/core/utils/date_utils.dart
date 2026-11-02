import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatApiDateTime(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime? parseApiDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}