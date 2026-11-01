import '../../shared/session/session.dart';
import 'app_routes.dart';

enum RouteGuardResult {
  allow,

  /// Belum masuk -> layar Masuk.
  requireSignIn,
}

/// Aturan akses rute. Urutan pemeriksaan: login.
class RouteGuards {
  const RouteGuards(this._session);
  final Session _session;

  static const _protected = {
    AppRoutes.family,
    AppRoutes.main,
    AppRoutes.memberProfile,
  };

  RouteGuardResult check(String name) {
    // Akses rute langsung tanpa login -> kembali ke Sign in.
    if (_protected.contains(name) && !_session.isLoggedIn) return RouteGuardResult.requireSignIn;
    return RouteGuardResult.allow;
  }
}
