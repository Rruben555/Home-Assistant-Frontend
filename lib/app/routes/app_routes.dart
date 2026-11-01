/// Nama rute. Hanya konstanta tanpa import, jadi aman dipakai fitur mana pun
/// untuk berpindah layar. Peta rute ke layar ada di app_router.dart.
class AppRoutes {
  static const signIn = '/sign-in';
  static const register = '/register';
  static const family = '/family'; // layar pertama setelah masuk (daftar / pilih keluarga)
  static const main = '/main';
  static const memberProfile = '/member/profile'; // arguments: String memberId
}
