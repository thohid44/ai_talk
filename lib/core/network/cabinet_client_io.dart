import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createPlatformCabinetClient() {
  final io = HttpClient();
  // Promo host certificate is expired.
  io.badCertificateCallback = (certificate, host, port) {
    return host == 'api-forexcopy.contentdatapro.com';
  };
  return IOClient(io);
}
