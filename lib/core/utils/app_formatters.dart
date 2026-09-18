abstract final class AppFormatters {
  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String money(double amount, String currency) {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  static String date(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')} '
        '${_months[value.month - 1]}, ${value.year}';
  }

  static String time(DateTime value) {
    final int hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final String minute = value.minute.toString().padLeft(2, '0');
    final String period = value.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  static String dateAndTime(DateTime value) {
    return '${date(value)} · ${time(value)}';
  }

  static String timeRange(DateTime start, DateTime end) {
    return '${time(start)} - ${time(end)}';
  }
}
