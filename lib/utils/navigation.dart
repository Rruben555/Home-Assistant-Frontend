import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Kembali ke layar sebelumnya. Bila layar dibuka langsung lewat URL
/// (tidak ada layar sebelumnya), pindah ke [fallback].
void goBackOrHome(BuildContext context, [String fallback = '/']) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}