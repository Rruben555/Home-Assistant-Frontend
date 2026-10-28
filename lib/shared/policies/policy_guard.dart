import '../../cores/errors/app_exception.dart';

const adminOnlyMessage = 'Hanya admin yang dapat melakukan tindakan ini.';

/// Dipakai repository untuk menolak aksi: lempar [AppException] bila [allowed] false.
void requireAllowed(bool allowed, [String message = adminOnlyMessage]) {
  if (!allowed) throw AppException(message);
}
