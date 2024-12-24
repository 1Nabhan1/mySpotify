import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Model/library_playlist_model.dart';

class LibraryController extends GetxController {
  late Future<List<Items>> futurePlaylists;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    futurePlaylists = Apiservices().fetchPlaylists();
  }
}
