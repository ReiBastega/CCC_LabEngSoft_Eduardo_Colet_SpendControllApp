class AuthException implements Exception {
  String? code;

  AuthException({
    this.code,
  }) {
    if (code != null) {
      code = code!.replaceAll('-', '').replaceAll('/', '');
    }
  }
}
