import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, h:mm a');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE, MMM d');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeekFormat.format(date);
  }

  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} – ${formatTime(end)}';
  }

  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} – ${formatDate(end)}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
