import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.nextFocusNode,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
  });

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction:
              textInputAction ?? (nextFocusNode != null ? TextInputAction.next : null),
          focusNode: focusNode,
          obscureText: obscureText,
          autofillHints: autofillHints,
          onFieldSubmitted: (value) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
            onSubmitted?.call(value);
          },
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            prefixIcon:
                icon != null ? Icon(icon, color: AppColors.textMuted, size: 20) : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: _border(AppColors.divider),
            enabledBorder: _border(AppColors.divider),
            focusedBorder: _border(AppColors.primary),
            errorBorder: _border(AppColors.priorityHigh),
            focusedErrorBorder: _border(AppColors.priorityHigh),
          ),
        ),
      ],
    );
  }
}