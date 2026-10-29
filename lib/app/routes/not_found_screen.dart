import 'package:flutter/material.dart';
import '../../cores/ui/app_scaffold.dart';
import '../../cores/ui/empty_state.dart';
import '../../shared/session/session.dart';
import 'app_routes.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    super.key,
    required this.session,
    this.message = 'Halaman yang kamu cari tidak tersedia.',
  });
  final Session session;
  final String message;

  void _back(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, session.isLoggedIn ? AppRoutes.main : AppRoutes.signIn, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        showAppBar: false,
        body: EmptyState(
          icon: Icons.explore_off_outlined,
          title: 'Tidak ditemukan',
          message: message,
          actionLabel: 'Kembali',
          onAction: () => _back(context),
        ),
      );
}
