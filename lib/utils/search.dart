/// Pencarian sederhana tanpa membedakan huruf besar/kecil.
///
/// [query] dipecah per kata; setiap kata harus muncul di salah satu
/// [fields] (judul, deskripsi, kategori, nama anggota, dst.). Query kosong
/// berarti semua cocok.
bool matchesSearch(String query, Iterable<String?> fields) {
  final tokens = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return true;
  final haystack = fields.whereType<String>().join(' ').toLowerCase();
  return tokens.every((t) => haystack.contains(t));
}
