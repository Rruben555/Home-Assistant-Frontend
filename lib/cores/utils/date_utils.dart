import 'package:flutter/material.dart' show TimeOfDay;

class AppDateUtils {
  static const _short = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  static const _long = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static String formatDate(DateTime d) => '${d.day} ${_short[d.month - 1]} ${d.year}';
  static String formatLongDate(DateTime d) => '${d.day} ${_long[d.month - 1]} ${d.year}';
  static String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
  static String formatTimeOfDay(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  static String relativeDay(DateTime d) {
    final diff = dateOnly(d).difference(dateOnly(DateTime.now())).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == -1) return 'Kemarin';
    if (diff == 1) return 'Besok';
    return formatDate(d);
  }
}
