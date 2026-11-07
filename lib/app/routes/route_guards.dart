import '../../shared/session/session.dart';
import 'app_routes.dart';

enum RouteGuardResult {
  allow,

  /// Belum masuk -> layar Masuk.
  requireSignIn,

  /// Belum memilih keluarga -> layar keluarga.
  requireFamily,
}

/// Aturan akses rute. Urutan pemeriksaan: login, keluarga terpilih.
class RouteGuards {
  const RouteGuards(this._session);
  final Session _session;

  static const _protected = {
    AppRoutes.family,
    AppRoutes.familyChoice,
    AppRoutes.main,
    AppRoutes.memberProfile,
  };

  RouteGuardResult check(String name) {
    // Akses rute langsung tanpa login -> kembali ke Sign in.
    if (_protected.contains(name) && !_session.isLoggedIn) return RouteGuardResult.requireSignIn;
    // Beranda butuh keluarga terpilih.
    if (name == AppRoutes.main && _session.familyId == null) return RouteGuardResult.requireFamily;
    return RouteGuardResult.allow;
  }
}
