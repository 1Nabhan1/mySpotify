import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/home_screen/models/album_model.dart';
import 'package:spotify_prj/presentation/home_screen/models/category_model.dart';
import 'package:spotify_prj/presentation/home_screen/models/new_releases.dart';
import 'package:spotify_prj/presentation/home_screen/models/top_artist.dart';
import 'package:spotify_prj/presentation/home_screen/models/user_details_model.dart';

import '../../LibraryScreen/Model/library_playlist_model.dart';
import '../models/recent_model.dart';
import '../models/top_tracks_model.dart';

class HomeController extends GetxController {
  late Future<recent_play?> futureRecent;
  late Future<CategoryModel?> futureCategories;
  late Future<TopTracks?> futureTopTracks;
  late Future<AlbumList?> futureAlbumList;
  late Future<NewReleases?> futureNewRelease;
  late Future<TopArtist?> futureArtists;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late InAppWebViewController webViewController;
  RxMap userData = {}.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchUsrDetails();
    futureRecent = ApiServices().fetchRecentList();
    futureCategories = ApiServices().fetchCategory();
    futureTopTracks = ApiServices().fetchTopTracks();
    futureAlbumList = ApiServices().fetchAlbums();
    futureNewRelease = ApiServices().fetchNewRelease();
    futureArtists = ApiServices().fetchArtists();
  }

  void fetchUsrDetails() async {
    try {
      userData.value = await ApiServices().userData();
    } catch (e) {
      print(e);
    }
  }
}
