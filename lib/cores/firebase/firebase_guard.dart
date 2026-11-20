import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../errors/app_exception.dart';

const _networkMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet lalu coba lagi.';
const _timeout = Duration(seconds: 20);

/// Jalankan panggilan Firebase; semua error diubah menjadi [AppException] berbahasa Indonesia
/// agar layar (AsyncBuilder / runAction) menampilkannya apa adanya.
/// Timeout dipasang karena penulisan Firestore menunggu server dan bisa menggantung saat offline.
Future<T> firebaseCall<T>(Future<T> Function() action) async {
  try {
    return await action().timeout(_timeout);
  } on AppException {
    rethrow;
  } on TimeoutException {
    throw const AppException(_networkMessage);
  } on FirebaseAuthException catch (e) {
    throw AppException(_authMessage(e));
  } on FirebaseException catch (e) {
    throw AppException(_dbMessage(e));
  }
}

String _authMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
    case 'invalid-login-credentials':
      return 'Email atau password salah. Periksa kembali.';
    case 'email-already-in-use':
      return 'Email sudah terdaftar. Gunakan email lain atau masuk.';
    case 'weak-password':
      return 'Password terlalu lemah. Gunakan password yang lebih panjang.';
    case 'invalid-email':
      return 'Format email tidak valid.';
    case 'user-disabled':
      return 'Akun ini dinonaktifkan.';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
    case 'network-request-failed':
      return _networkMessage;
    case 'requires-recent-login':
      return 'Sesi sudah terlalu lama. Silakan keluar lalu masuk lagi.';
    default:
      return 'Autentikasi gagal (${e.code}).';
  }
}

String _dbMessage(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'Kamu tidak memiliki izin untuk tindakan ini.';
    case 'unavailable':
    case 'deadline-exceeded':
      return _networkMessage;
    case 'not-found':
      return 'Data tidak ditemukan.';
    case 'already-exists':
      return 'Data tersebut sudah ada.';
    case 'failed-precondition':
      return 'Konfigurasi database belum lengkap (${e.message}).';
    default:
      return 'Terjadi kesalahan pada server (${e.code}).';
  }
}
