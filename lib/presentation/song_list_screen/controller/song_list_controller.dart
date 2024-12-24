import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart';

class SongListController extends GetxController {
  final arguments = Get.arguments;
  late Future<PlaylistTrackResponse?> songList;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    songList = Apiservices().fetchSongList(arguments['id']);
  }
}
