import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../cores/ui/app_snackbar.dart';

/// Kode keluarga di kanan nama keluarga, dengan satu ikon salin.
class FamilyCodeBox extends StatelessWidget {
  const FamilyCodeBox({super.key, required this.code});
  final String code;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) showAppSnack(context, 'Kode keluarga disalin');
  }

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadius.smR),
          child: Text(code,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.primary)),
        ),
        IconButton(
          tooltip: 'Salin kode keluarga',
          onPressed: () => _copy(context),
          icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
        ),
      ]);
}
