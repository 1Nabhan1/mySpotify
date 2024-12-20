import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class Constdetails {
  String Token = box.read('token');
}
