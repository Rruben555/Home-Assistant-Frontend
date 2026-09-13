/// Pengguna yang sedang masuk (tanpa kata sandi — kata sandi hanya
/// disimpan di dalam `AuthRepository`).
class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
