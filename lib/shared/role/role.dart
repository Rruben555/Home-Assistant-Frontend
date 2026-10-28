/// Peran anggota dalam satu keluarga. [label] adalah teks yang tampil di layar.
enum Role {
  admin('Admin'),
  member('Anggota');

  const Role(this.label);
  final String label;
}
