import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../utils/date_utils.dart';

/// Dua kolom "Tanggal | Waktu". Dipakai untuk Tenggat waktu dan Waktu selesai
/// agar tampilannya sama.
class DateTimeInfo extends StatelessWidget {
  const DateTimeInfo({super.key, required this.dateTime});
  final DateTime dateTime;

  Widget _col(String label, String value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.muted),
          const SizedBox(height: 2),
          Text(value, style: AppText.h3),
        ]),
      );

  @override
  Widget build(BuildContext context) => Row(children: [
        _col('Tanggal', AppDateUtils.formatDate(dateTime)),
        _col('Waktu', AppDateUtils.formatTime(dateTime)),
      ]);
}
