import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, required this.controller, required this.hint, required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppText.body,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
      );
}
