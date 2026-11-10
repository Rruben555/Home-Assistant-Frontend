import 'package:flutter/material.dart';
import '../../features/auth/auth.dart';
import '../../features/chores/chores.dart';
import '../../features/family/family.dart';
import '../../features/members/members.dart';
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

  /// Belum punya keluarga -> layar Belum ada keluarga; sudah punya -> daftar keluarga.
  Widget _familyEntry() =>
      _d.family.hasFamilies ? FamilyListScreen(auth: _d.auth, family: _d.family) : FamilyChoiceScreen(family: _d.family);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    final args = settings.arguments;

    switch (_guards.check(name)) {
      case RouteGuardResult.requireSignIn:
        return _page(const RouteSettings(name: AppRoutes.signIn), SignInScreen(auth: _d.auth));
      case RouteGuardResult.requireFamily:
        return _page(const RouteSettings(name: AppRoutes.family), _familyEntry());
      case RouteGuardResult.allow:
        break;
    }

    switch (name) {
      case AppRoutes.signIn:
        return _page(settings, SignInScreen(auth: _d.auth));
      case AppRoutes.register:
        return _page(settings, RegisterScreen(auth: _d.auth));
      case AppRoutes.family:
        return _page(settings, _familyEntry());
      case AppRoutes.familyChoice:
        return _page(settings, FamilyChoiceScreen(family: _d.family));
      case AppRoutes.main:
        return _page(settings, MainShell(dependencies: _d));
      case AppRoutes.choreDetail:
        if (args is! String || args.isEmpty) {
          return _page(settings, _notFound('ID chore tidak valid.'));
        }
        return _page(
            settings,
            _d.session.isAdmin
                ? AdminChoreDetailScreen(choreId: args, chores: _d.chores, members: _d.members)
                : MemberChoreDetailScreen(choreId: args, chores: _d.chores, members: _d.members));
      case AppRoutes.choreForm:
        return _page(settings, _notFound('Form chore belum tersedia.'));
      case AppRoutes.memberProfile:
        if (args is! String || args.isEmpty) {
          return _page(settings, _notFound('ID anggota tidak valid.'));
        }
        return _page(
            settings,
            MemberProfileScreen(
              memberId: args,
              members: _d.members,
              familyName: _d.family.current?.name ?? '-',
            ));
      default:
        return _page(settings, _notFound());
    }
  }
}
