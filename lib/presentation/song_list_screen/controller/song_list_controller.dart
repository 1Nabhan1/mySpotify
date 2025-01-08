import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/artist_song_list.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart';

class SongListController extends GetxController {
  final arguments = Get.arguments;
  // late Future<PlaylistTrackResponse?> songList;
  late Future<List<Item>> songList;
  late Future<ArtistSongs?> artSongList;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    songList = ApiServices().fetchSongList(
      uri: arguments['uri'],
    );
    artSongList = ApiServices().fetchArtistSongList(arguments['uri']);
  }
}
