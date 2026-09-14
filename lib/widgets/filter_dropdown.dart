import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Satu pilihan pada [FilterDropdown]. `value == null` dipakai untuk "Semua".
class FilterOption<T> {
  final T? value;
  final String label;
  final IconData? icon;

  const FilterOption({required this.value, required this.label, this.icon});
}

/// Dropdown filter dengan label mengambang, gaya sama dengan field lain
/// (kartu putih, sudut 14). [value] harus cocok dengan salah satu [options].
class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<FilterOption<T>> options;
  final ValueChanged<T?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c),
      );

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return InputDecorator(
      isEmpty: false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        floatingLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: active ? AppColors.primaryDark : AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        border: _border(AppColors.divider),
        enabledBorder: _border(active ? AppColors.primary : AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          onChanged: onChanged,
          items: [
            for (final o in options)
              DropdownMenuItem<T?>(
                value: o.value,
                child: Row(
                  children: [
                    if (o.icon != null) ...[
                      Icon(o.icon, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(o.label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
