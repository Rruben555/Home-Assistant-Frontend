/// Keluarga / rumah tangga. Chore dan anggota selalu milik satu keluarga.
class Family {
  const Family({required this.id, required this.name, required this.code});
  final String id;
  final String name;

  /// Kode undangan unik untuk bergabung ke keluarga ini.
  final String code;
}
