import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';

import '../../LibraryScreen/Model/library_playlist_model.dart';
import '../models/recent_model.dart';

class HomeController extends GetxController {
  late Future<recent_play?> futureRecent;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    futureRecent = Apiservices().fetchRecentList();
  }
}
