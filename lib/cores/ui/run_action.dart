import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';
import 'app_snackbar.dart';

/// Helper submit: jalankan [action], lalu tangani hasilnya dengan cara yang sama di semua layar.
///
/// - [onBusy]: dipanggil `true` sebelum aksi dan `false` sesudahnya (hanya bila layar masih ada).
/// - [onSuccess]: dipanggil dengan hasil aksi bila berhasil dan layar masih ada.
/// - [onRetry]: bila diisi, snackbar error memuat tombol "Coba lagi" yang memanggilnya.
/// - [AppException] ditampilkan sebagai snackbar error. Error tak terduga dicatat lewat
///   [debugPrint] dan ditampilkan sebagai "Terjadi kesalahan: ..." kecuali [catchUnexpected] false
///   (error dilempar ulang).
///
/// Mengembalikan true bila aksi berhasil.
Future<bool> runAction<T>(
  BuildContext context, {
  required Future<T> Function() action,
  void Function(bool busy)? onBusy,
  void Function(T value)? onSuccess,
  VoidCallback? onRetry,
  String logLabel = 'Aksi',
  bool catchUnexpected = true,
}) async {
  onBusy?.call(true);
  try {
    final result = await Result.guard<T>(action);
    if (!context.mounted) return result.isSuccess;
    if (result is Failure<T>) {
      final AppException error = result.error;
      showAppSnack(
        context,
        error.message,
        isError: true,
        actionLabel: onRetry == null ? null : AppConst.retryLabel,
        onAction: onRetry,
      );
      return false;
    }
    onSuccess?.call((result as Success<T>).value);
    return true;
  } catch (e, st) {
    if (!catchUnexpected) rethrow;
    debugPrint('$logLabel gagal: $e\n$st');
    if (context.mounted) showAppSnack(context, 'Terjadi kesalahan: $e', isError: true);
    return false;
  } finally {
    if (context.mounted) onBusy?.call(false);
  }
}
