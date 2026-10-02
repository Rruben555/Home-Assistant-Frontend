# Home Assistant — Aplikasi Manajemen Aktivitas Rumah Tangga

Aplikasi Flutter untuk mengatur aktivitas rumah tangga (kebersihan, cucian, tagihan, belanja, dll.), menugaskannya ke anggota keluarga, dan melihat riwayat penyelesaiannya. Seluruh data adalah **data simulasi in-memory** (tanpa backend dan tanpa database), jadi semua perubahan hilang saat aplikasi dijalankan ulang.

## Fitur Utama

| Modul | Ringkasan |
|---|---|
| Autentikasi | Daftar, masuk, keluar, ubah profil, ganti kata sandi, hapus akun |
| Aktivitas (CRUD 1) | Tambah/ubah/hapus aktivitas, kategori, prioritas, pengulangan, tandai selesai, urungkan |
| Anggota Keluarga (CRUD 2) | Tambah/ubah/hapus anggota, peran, status aktif, relasi ke aktivitas |
| Riwayat | Linimasa aktivitas selesai, filter rentang waktu, pencarian, hapus catatan |
| AI Asisten | Chat demo dengan saran cepat (balasan tetap, belum tersambung ke AI sungguhan) |
| Responsif | Bottom navigation (HP), navigation rail (tablet), rail extended + multi-kolom (web/desktop) |

## Prasyarat

- Flutter SDK **3.16 atau lebih baru** (kode memakai Dart 3: switch expression dan record, `MediaQuery.sizeOf`, `TextScaler.clamp`)
- Salah satu target: emulator/perangkat Android
- Cek lingkungan: `flutter doctor`

## Setup

```bash
# 1. Buat kerangka projek (nama bebas)
flutter create home_assistant
cd home_assistant

# 2. Ganti folder lib/ bawaan dengan lib/ dari projek ini
rm -rf lib
cp -r /path/ke/lib ./lib          # Windows: robocopy atau salin manual

# 3. Pasang dependensi
flutter pub add go_router
flutter pub add flutter_localizations --sdk=flutter

# 4. Unduh paket
flutter pub get
```

Bila Anda sudah punya `pubspec.yaml` sendiri, pastikan dua dependensi ini ada:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  go_router: any   # ganti dengan versi yang dipakai tim
```

> Paket yang diimpor oleh kode: `flutter`, `flutter_localizations`, dan `go_router`. Tidak ada paket lain.

## Perintah Run

```bash
flutter run -d chrome        # Web (paling mudah untuk demo)
flutter run -d windows       # Desktop (atau: macos / linux)
flutter run                  # Perangkat/emulator yang terhubung
flutter run -d <device-id>   # Pilih perangkat tertentu (lihat: flutter devices)
```

## Akun Demo

| Email | Kata sandi | Nama |
|---|---|---|
| `sarah@example.com` | `password123` | Bu Sarah |

Pada build **debug**, halaman Masuk menampilkan tombol **"Isi akun demo"** yang mengisi kedua kolom otomatis. Pada build release tombol ini disembunyikan. Untuk menampilkannya di build rilis, ubah `showDemoLogin` di `lib/config/app_config.dart` menjadi `true`.

Akun baru bisa dibuat lewat halaman **Daftar** (kata sandi minimal 8 karakter, kombinasi huruf dan angka). Akun disimpan hanya di memori.

## Data Dummy

Sumber data: `lib/data/dummy_data.dart` dan `lib/data/chat_seed.dart`. Tanggal aktivitas dibuat **relatif terhadap hari ini**, sehingga demo selalu terlihat relevan kapan pun dijalankan.

| Data | Jumlah | Keterangan |
|---|---|---|
| Anggota keluarga | 5 | Bu Sarah (Ibu), Pak Andi (Ayah), Kirana (Anak), Bima (Anak, **nonaktif**), Bu Inah (Asisten RT) |
| Aktivitas | 22 | 5 Cleaning, 3 Laundry, 3 Bills, 3 Maintenance, 3 Gardening, 3 Shopping, 2 Other |
| Pengulangan | 22 | 5 harian, 6 mingguan, 7 bulanan, 4 sekali |
| Prioritas | 22 | 4 tinggi, 10 sedang, 8 rendah |
| Penugasan | 22 | Ibu 6, Ayah 5, ART 4, Kirana 3, Bima 2, **belum ditugaskan 2** |
| Sebaran tanggal | 22 | 2 sudah lewat (terlambat), 7 hari ini, 13 mendatang (hingga +9 hari) |
| Riwayat | 8 | Tersebar dari kemarin sampai 40 hari lalu |
| Akun | 1 | Akun demo di atas |
| Saran cepat AI | 3 | "Rekomendasi jadwal mingguan", "Cara bersihkan noda kusam", "Tips hemat energi rumah" |

Data sengaja memuat kasus uji: aktivitas terlambat, aktivitas tanpa penanggung jawab, anggota nonaktif yang masih punya tugas, dan aktivitas berulang di semua pola.

## Skenario Simulasi

Jalankan berurutan atau pilih sesuai kebutuhan demo. Kotak "Hasil" adalah yang seharusnya terlihat.

### 1. Masuk dan alihan halaman
1. Buka aplikasi tanpa masuk. **Hasil:** diarahkan ke `/login`.
2. Coba masuk dengan kata sandi salah. **Hasil:** banner "Email atau kata sandi salah."
3. Klik "Isi akun demo", lalu "Masuk". **Hasil:** loading singkat, lalu Beranda dengan sapaan "Halo, Bu Sarah!".

### 2. Kelola aktivitas (CRUD)
1. Beranda → **Tugas Baru** → isi nama, kategori, tanggal, waktu, pengulangan, prioritas, penanggung jawab → **Simpan Aktivitas**. **Hasil:** snackbar sukses, aktivitas muncul di daftar.
2. Buka salah satu aktivitas → **Ubah** → simpan. **Hasil:** perubahan tampil di daftar dan detail.
3. **Hapus** → konfirmasi → klik **Urungkan** di snackbar. **Hasil:** aktivitas kembali.

### 3. Selesaikan aktivitas berulang dan riwayat
1. Pada "Membersihkan Kamar Mandi" (mingguan), ketuk tombol selesai. **Hasil:** jadwal maju ke minggu berikutnya, catatan baru masuk tab Riwayat.
2. Klik **Urungkan**. **Hasil:** jadwal kembali ke semula, catatan riwayat hilang.
3. Buka tab **Riwayat**, ganti rentang Minggu Ini / Bulan Ini / Semua, lalu hapus satu catatan.

### 4. Cari dan filter
1. Di Beranda ketik "pln" pada kolom cari. **Hasil:** hanya tagihan listrik.
2. Reset, pilih kategori **Cleaning**, lalu anggota **Bu Sarah**. **Hasil:** hanya irisan keduanya.
3. Pilih **Belum ditugaskan**. **Hasil:** 2 aktivitas (iuran keamanan dan rapikan gudang).
4. Cari kata yang tidak ada. **Hasil:** tampilan kosong "Tidak ada aktivitas yang cocok".

### 5. Kelola anggota dan relasi
1. Tab **Keluarga** → **Anggota Baru** → simpan. Coba nama yang sama dengan anggota lain. **Hasil:** "Nama ini sudah dipakai anggota lain".
2. Hapus "Pak Andi". **Hasil:** semua aktivitas Pak Andi menjadi "Belum ditugaskan" (tidak ada relasi menggantung).
3. Klik **Urungkan** pada snackbar untuk memulihkan anggota.

### 6. Validasi form
- Nama aktivitas kosong, kurang dari 3 karakter, atau lebih dari 60 karakter → pesan galat.
- Deskripsi lebih dari 200 karakter → pesan galat.
- Tanggal/jam yang sudah lewat untuk aktivitas baru → "Tanggal & waktu sudah lewat."
- Ketuk **Simpan** berkali-kali dengan cepat → hanya satu aktivitas tersimpan.

### 7. Akun dan profil
1. Profil → **Ubah profil** (nama/email), lalu **Ganti kata sandi** (kata sandi lama harus benar dan berbeda dari yang baru).
2. **Keluar** → konfirmasi. **Hasil:** kembali ke halaman Masuk.
3. Daftar akun baru, lalu **Hapus Akun** dengan kata sandi. **Hasil:** akun hilang dan tidak bisa masuk lagi.

### 8. Rute dan halaman tidak ditemukan
- Web: buka `/task/tidak-ada` → halaman "Detail Aktivitas" dengan pesan `Aktivitas dengan ID "tidak-ada" tidak ditemukan.`
- Web: buka `/halaman-ngawur` → "Halaman tidak ditemukan".
- Web belum masuk, buka `/riwayat` → diarahkan ke `/login?from=/riwayat`, dan setelah masuk kembali ke `/riwayat`.

### 9. Responsif
Ubah lebar jendela (Chrome/desktop): di bawah 600 px muncul bottom navigation; 600–899 px navigation rail; 900 px ke atas rail extended dengan daftar tugas dua kolom.

### 10. AI Asisten
Buka tab **AI**, ketuk saran cepat atau ketik pesan. **Hasil:** indikator "Sedang mengetik...", lalu balasan demo tetap. Tombol kirim dikunci selama balasan diproses.

### 11. Simulasi galat + "Coba Lagi" (butuh mengaktifkan mode debug)
Mode uji galat sudah ada di kode tetapi **dinonaktifkan lewat komentar bertanda `// [DEBUG]`**. Untuk mengaktifkannya:

1. Cari semua baris yang diawali `// [DEBUG]` di:
   `repository/task_repository.dart`, `repository/member_repository.dart`, `repository/auth_repository.dart`, `screens/profile_screen.dart`, `screens/login_screen.dart`, `screens/register_screen.dart`, `widgets/auth_layout.dart`.
2. Hapus penanda `// [DEBUG]` (kode di sebelahnya dipertahankan). Di VS Code: *Find* `// \[DEBUG\] ` dengan regex, *Replace* kosong.
3. Jalankan ulang. Di **Profil** muncul saklar **"Simulasikan Galat Memuat Data"** dan tombol **"Reset Data Simulasi"**; di halaman Masuk/Daftar muncul saklar galat sistem.
4. Aktifkan saklar, lalu buka Beranda/Keluarga/Riwayat. **Hasil:** tampilan galat dengan tombol **Coba Lagi**. Matikan saklar, tekan **Coba Lagi**, data tampil.

## Struktur Projek

```
lib/
├── main.dart              # Titik masuk, penyedia repository, tema, lokalisasi id-ID
├── app_router.dart        # Rute go_router + penjaga login (redirect)
├── config/app_config.dart # Saklar fitur demo
├── models/                # HouseholdTask, HistoryEntry, FamilyMember, AppUser, ChatMessage
├── repository/            # TaskRepository, MemberRepository, AuthRepository (in-memory, async simulasi)
├── data/                  # dummy_data.dart, chat_seed.dart
├── screens/               # 12 layar + 1 shell navigasi (lihat docs/DOKUMEN_RINGKAS.md)
├── widgets/               # Komponen UI bersama
├── utils/                 # Validator, formatter tanggal, pencarian, responsif, aksi tugas/anggota
├── common/async_state.dart# Pola loading / data / error
└── theme/app_theme.dart   # Warna dan tema
```

## Catatan dan Batasan

- **Tidak ada persistensi.** Menutup/menyegarkan aplikasi mengembalikan semua data ke data dummy.
- **Kata sandi disimpan apa adanya di memori** hanya karena ini simulasi tanpa backend. Jangan dipakai seperti ini di aplikasi nyata.
- **AI Asisten hanya demo.** Balasan selalu sama. Kartu saran + tombol "Tambahkan ke Jadwal" dimatikan lewat `AppConfig.enableAiSuggestionCards = false`.
- Saklar "Notifikasi Pengingat" di Profil hanya tampilan (belum memicu notifikasi sungguhan).
- Repository dirancang agar bisa diganti Room/SQLite atau API tanpa mengubah UI.

## Dokumentasi Lain

- [`docs/DOKUMEN_RINGKAS.md`](docs/DOKUMEN_RINGKAS.md) — persona, peta layar, model data, pembagian kontribusi
- [`docs/MATRIKS_UJI.md`](docs/MATRIKS_UJI.md) — matriks 24 uji beserta bukti perbaikan
