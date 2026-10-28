import 'app_exception.dart';

/// Hasil sebuah aksi: berhasil membawa nilai, gagal membawa [AppException].
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  /// Jalankan [action]. [AppException] dibungkus menjadi [Failure];
  /// error tak terduga tetap dilempar ke pemanggil.
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on AppException catch (e) {
      return Failure<T>(e);
    }
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}
