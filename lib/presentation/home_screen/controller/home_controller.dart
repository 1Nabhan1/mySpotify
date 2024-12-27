import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/home_screen/models/album_model.dart';
import 'package:spotify_prj/presentation/home_screen/models/category_model.dart';
import 'package:spotify_prj/presentation/home_screen/models/new_releases.dart';

import '../../LibraryScreen/Model/library_playlist_model.dart';
import '../models/recent_model.dart';
import '../models/top_tracks_model.dart';

class HomeController extends GetxController {
  late Future<recent_play?> futureRecent;
  late Future<CategoryModel?> futureCategories;
  late Future<TopTracks?> futureTopTracks;
  late Future<AlbumList?> futureAlbumList;
  late Future<NewReleases?> futureNewRelease;


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    futureRecent = Apiservices().fetchRecentList();
    futureCategories = Apiservices().fetchCategory();
    futureTopTracks = Apiservices().fetchTopTracks();
    futureAlbumList = Apiservices().fetchAlbums();
    futureNewRelease = Apiservices().fetchNewRelease();
  }
}
