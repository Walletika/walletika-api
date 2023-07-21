import 'dart:io';

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void httpOverridesInit() {
  // Bypass `CERTIFICATE_VERIFY_FAILED` exception by overrides http client
  HttpOverrides.global = _MyHttpOverrides();
}
