import 'package:flutter/material.dart';
import '../di/injection.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';
import 'not_found_screen.dart';

/// Peta nama rute -> layar. Layar menerima controller dari [AppDependencies].
class AppRouter {
  AppRouter(this._d);

  final AppDependencies _d;

  static MaterialPageRoute<T> _page<T>(RouteSettings s, Widget w) =>
      MaterialPageRoute<T>(settings: s, builder: (_) => w);

  NotFoundScreen _notFound([String? message]) => message == null
      ? NotFoundScreen(session: _d.session)
      : NotFoundScreen(session: _d.session, message: message);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';

    switch (name) {
      case AppRoutes.main:
        return _page(settings, MainShell(dependencies: _d));
      default:
        return _page(settings, _notFound());
    }
  }
}
