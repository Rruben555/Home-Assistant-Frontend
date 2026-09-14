import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Scaffold dengan latar gradasi yang sama dengan halaman utama. Dipakai
/// oleh layar yang dibuka di atas shell (detail, form, masuk, dll.).
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const GradientScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: kPageGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
