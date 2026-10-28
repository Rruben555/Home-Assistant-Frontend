import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            minLines: maxLines > 1 ? 3 : 1,
            maxLength: maxLength,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            style: AppText.body,
            decoration: InputDecoration(hintText: hint, helperText: helper, suffixIcon: suffixIcon),
          ),
        ],
      );
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.validator,
  });

  final String label;
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<T>(
            // ignore: deprecated_member_use
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            isExpanded: true,
            borderRadius: AppRadius.mdR,
            hint: hint == null ? null : Text(hint!, style: AppText.muted),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          ),
        ],
      );
}
