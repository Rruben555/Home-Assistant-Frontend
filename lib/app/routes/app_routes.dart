/// Nama rute. Hanya konstanta tanpa import, jadi aman dipakai fitur mana pun
/// untuk berpindah layar. Peta rute ke layar ada di app_router.dart.
class AppRoutes {
  static const signIn = '/sign-in';
  static const register = '/register';
  static const family = '/family'; // layar pertama setelah masuk (daftar / pilih keluarga)
  static const familyChoice = '/family/choice'; // buat atau gabung keluarga
  static const main = '/main';
  static const choreDetail = '/chore/detail'; // arguments: String choreId
  static const choreForm = '/chore/form'; // admin saja. arguments: String? choreId (null = buat baru)
  static const memberProfile = '/member/profile'; // arguments: String memberId
}
