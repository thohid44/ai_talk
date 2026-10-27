import 'package:ai_talk_test/core/network/cabinet_client_stub.dart'
    if (dart.library.io) 'package:ai_talk_test/core/network/cabinet_client_io.dart';
import 'package:http/http.dart' as http;

http.Client createCabinetClient() => createPlatformCabinetClient();
