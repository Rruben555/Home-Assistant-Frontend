import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kolom pencarian berbentuk pil dengan bayangan lembut. Tombol hapus (X)
/// muncul otomatis saat ada teks. Controller dimiliki oleh layar pemakai
/// supaya teks pencarian tetap ada ketika data dimuat ulang.
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Cari aktivitas...',
    this.onClear,
  });

  OutlineInputBorder _border(Color c, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: c, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(fontSize: 14.5, color: AppColors.textDark),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 14, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 22),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Hapus pencarian',
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 20),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  onClear?.call();
                },
              );
            },
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: _border(AppColors.divider),
          enabledBorder: _border(AppColors.divider),
          focusedBorder: _border(AppColors.primary, 1.5),
        ),
      ),
    );
  }
}
