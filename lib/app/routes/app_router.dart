import 'package:flutter/material.dart';
import '../../cores/ui/app_scaffold.dart';
import '../../cores/ui/empty_state.dart';
import '../../features/auth/auth.dart';
import '../di/injection.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';
import 'not_found_screen.dart';
import 'route_guards.dart';

/// Peta nama rute -> layar. Layar menerima controller dari [AppDependencies].
class AppRouter {
  AppRouter(this._d) : _guards = RouteGuards(_d.session);

  final AppDependencies _d;
  final RouteGuards _guards;

  static MaterialPageRoute<T> _page<T>(RouteSettings s, Widget w) =>
      MaterialPageRoute<T>(settings: s, builder: (_) => w);

  NotFoundScreen _notFound([String? message]) => message == null
      ? NotFoundScreen(session: _d.session)
      : NotFoundScreen(session: _d.session, message: message);

  /// Sementara: layar keluarga belum dibuat, jadi langsung pakai keluarga contoh (f1).
  Widget _familyPlaceholder() => Builder(
        builder: (context) => AppScaffold(
          showAppBar: false,
          body: EmptyState(
            icon: Icons.home_work_outlined,
            title: 'Keluarga',
            message: 'Pemilihan keluarga belum tersedia. Lanjutkan dengan keluarga contoh.',
            actionLabel: 'Lanjut ke Beranda',
            onAction: () {
              _d.session.selectFamily('f1');
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
            },
          ),
        ),
      );

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';

    switch (_guards.check(name)) {
      case RouteGuardResult.requireSignIn:
        return _page(const RouteSettings(name: AppRoutes.signIn), SignInScreen(auth: _d.auth));
      case RouteGuardResult.allow:
        break;
    }

    switch (name) {
      case AppRoutes.signIn:
        return _page(settings, SignInScreen(auth: _d.auth));
      case AppRoutes.register:
        return _page(settings, RegisterScreen(auth: _d.auth));
      case AppRoutes.family:
        return _page(settings, _familyPlaceholder());
      case AppRoutes.main:
        return _page(settings, MainShell(dependencies: _d));
      default:
        return _page(settings, _notFound());
    }
  }
}
