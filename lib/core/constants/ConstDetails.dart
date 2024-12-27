import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class Constdetails {
  String token = box.read('token');
  String refreshToken = box.read('refreshToken');
  String clientId = dotenv.env['CLIENT_ID'] ?? '';
  String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';
}
