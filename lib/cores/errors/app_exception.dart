class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
