import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

void showAppSnack(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: isError ? AppColors.error : AppColors.textDark,
    action: actionLabel == null
        ? null
        : SnackBarAction(label: actionLabel, textColor: Colors.white, onPressed: onAction ?? () {}),
  ));
}
