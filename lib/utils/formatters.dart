import 'package:flutter/material.dart';

const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Tambah satu bulan; tanggal disesuaikan bila bulan tujuan lebih pendek
/// (mis. 31 Jan -> 28/29 Feb).
DateTime addOneMonth(DateTime d) {
  final y = d.month == 12 ? d.year + 1 : d.year;
  final m = d.month == 12 ? 1 : d.month + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, d.day > lastDay ? lastDay : d.day);
}

String formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String formatTimeWib(TimeOfDay t) => '${formatTime(t)} WIB';

String formatClock(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// "19 Maret 2026"
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "Rabu, 19 Maret 2026"
String formatDateLong(DateTime d) => '${_days[d.weekday - 1]}, ${formatDate(d)}';

/// "Rabu, 19 Mar"
String formatDateShort(DateTime d) =>
    '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1].substring(0, 3)}';

/// Label relatif: Hari ini / Besok / Kemarin, selain itu tanggal singkat.
String relativeDate(DateTime d, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final diff = dateOnly(d).difference(today).inDays;
  return switch (diff) {
    0 => 'Hari ini',
    1 => 'Besok',
    -1 => 'Kemarin',
    _ => formatDateShort(d),
  };
}
