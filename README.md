# House Chore Manager

Aplikasi Flutter untuk mengatur chore rumah tangga: membuat chore, menugaskannya ke anggota keluarga, menandai selesai, dan melihat riwayat. Seluruh data adalah **simulasi in-memory** (tanpa backend dan database), jadi semua perubahan hilang saat aplikasi dijalankan ulang.

## Fitur

| Fitur | Ringkasan |
|---|---|
| Auth | Daftar, masuk, keluar, ubah nama dan password |
| Keluarga | Satu akun bisa ikut banyak keluarga: buat keluarga baru atau gabung dengan kode undangan, lalu pilih keluarga aktif |
| Anggota | Daftar anggota per keluarga, profil anggota, admin dapat mengubah peran dan menghapus anggota |
| Chore | Beranda dengan pencarian dan filter, detail, tandai selesai, form buat/ubah (khusus admin), riwayat |
| Chatbot | Asisten berbasis aturan (balasan dari kata kunci, belum memakai AI sungguhan) |
| Peran | Admin mengelola chore dan anggota; anggota biasa hanya menyelesaikan chore miliknya |

## Struktur Projek

```
lib/
├── main.dart              # Titik masuk: bootstrap() lalu runApp
├── app/                   # Perakitan aplikasi
│   ├── app.dart           # MaterialApp, tema, batas lebar konten
│   ├── bootstrap.dart     # Inisialisasi sebelum runApp
│   ├── di/injection.dart  # Satu-satunya tempat merakit repository + controller
│   ├── routes/            # app_routes (nama), app_router (peta), route_guards, not_found_screen
│   ├── shell/             # MainShell: navigasi tab
│   └── theme/             # Warna, jarak, gaya teks, ThemeData
├── cores/                 # Utilitas lintas-fitur tanpa logika bisnis
│   ├── config/  constants/  errors/  utils/  notification/  timezone/
│   └── ui/                # Komponen UI bersama (tombol, kartu, field, dialog, dst.)
├── shared/                # Konsep domain yang dipakai banyak fitur
│   ├── role/              # enum Role
│   ├── session/           # Session: akun masuk, keluarga terpilih, anggota saat ini
│   └── policies/          # Aturan hak akses (fungsi murni)
└── features/
    ├── auth/  members/  family/  chores/  chatbot/  profile/
        ├── <fitur>.dart   # Barrel: satu-satunya pintu masuk dari luar fitur
        ├── domain/        # Model dan kontrak repository
        ├── data/          # Implementasi in-memory + seed
        └── presentation/  # controllers/, screens/ (admin, member, universal), widgets/
```

### Aturan dependensi

- Urutan ketergantungan antar-fitur: `auth` → `members` → `family` → `chores` → `chatbot`; `profile` memakai `auth`, `members`, dan `family`.
- Fitur lain hanya boleh mengimpor **barrel** (`features/<nama>/<nama>.dart`), bukan file di dalamnya.
- Folder `data/` hanya diimpor oleh `app/di/injection.dart`. Mengganti repository (mis. ke Firebase) cukup dilakukan di sana, layar tidak berubah.
- `shared/` tidak mengenal fitur. `Session` mencari anggota lewat resolver yang diikat oleh DI.
- Hak akses ada di `shared/policies` dan dicek di repository, bukan hanya disembunyikan di UI.

## Menjalankan

Prasyarat: Flutter SDK dengan Dart `^3.13.2` (lihat `pubspec.yaml`).

```bash
flutter pub get
flutter run                 # perangkat/emulator yang terhubung
flutter run -d chrome       # web
flutter analyze
flutter test
```

Kunci API chatbot (opsional, belum dipakai oleh chatbot berbasis aturan) diberikan lewat `--dart-define`:

```bash
flutter run --dart-define=CHATBOT_API_KEY=isi_kunci_di_sini
```

## Akun dan Data Demo

| Email | Password | Keterangan |
|---|---|---|
| `ven@example.com` | `ven12345` | Admin di **Keluarga Ven** (`VEN482`), anggota biasa di **Rumah Kos Melati** (`MLT735`) |

- Seed: 2 keluarga, 8 anggota, 27 chore (24 di Keluarga Ven, 3 di Rumah Kos Melati). Tanggal chore dibuat relatif terhadap hari ini.
- Akun baru dibuat lewat layar **Daftar** (password minimal 8 karakter). Setelah itu buat keluarga baru atau gabung dengan kode di atas.
- Jeda 700 ms pada repository sengaja ditambahkan agar kondisi loading dan error terlihat (`AppConfig.simulatedDelay`).

## Catatan

- Tidak ada persistensi. Menutup aplikasi mengembalikan semua data ke seed.
- Password disimpan apa adanya di memori hanya karena ini simulasi. Jangan dipakai seperti ini di aplikasi nyata.
- Notifikasi lokal dan zona waktu baru berupa titik inisialisasi kosong (`cores/notification`, `cores/timezone`).
