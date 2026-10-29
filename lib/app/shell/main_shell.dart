import 'package:flutter/material.dart';
import '../../cores/ui/app_scaffold.dart';
import '../../cores/ui/empty_state.dart';
import '../../features/auth/auth.dart';
import '../di/injection.dart';

/// Kerangka layar utama. Tahap ini baru berisi Beranda sementara dengan tombol keluar;
/// tab lain ditambahkan bersama fitur masing-masing.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.dependencies});
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => AppScaffold(
        showAppBar: false,
        body: EmptyState(
          icon: Icons.home_outlined,
          title: 'Beranda',
          message: 'Fondasi aplikasi sudah berjalan. Fitur ditambahkan bertahap.',
          actionLabel: 'Keluar',
          onAction: () => confirmAndLogout(context, dependencies.auth),
        ),
      );
}
