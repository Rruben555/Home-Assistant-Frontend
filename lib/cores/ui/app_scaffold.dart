import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// Kerangka layar: [Scaffold] + [SafeArea]. Bila [showAppBar] true, app bar polos
/// (tanpa judul) dengan tombol kembali bawaan, sama seperti layar form dan detail.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.showAppBar = true,
    this.backgroundColor,
    this.bottomNavigationBar,
  });

  final Widget body;
  final bool showAppBar;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: showAppBar
            ? AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: AppColors.textDark,
              )
            : null,
        body: SafeArea(child: body),
        bottomNavigationBar: bottomNavigationBar,
      );
}
