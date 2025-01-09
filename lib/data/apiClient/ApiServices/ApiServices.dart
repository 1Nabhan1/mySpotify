import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/core/constants/api_methods.dart';
import 'package:spotify_prj/data/apiClient/ApiList/Apilist.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Model/library_playlist_model.dart'
    as libry;
import 'package:spotify_prj/presentation/Player_screen/controllers/audio_controller.dart';
import 'package:spotify_prj/presentation/home_screen/controller/home_controller.dart';
import 'package:spotify_prj/presentation/home_screen/models/new_releases.dart';
import 'package:spotify_prj/presentation/home_screen/models/top_artist.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/artist_song_list.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart'
    as sg_list;
import 'package:spotify_prj/routes/PageList.dart';

import '../../../presentation/SearchScreen/SearchController/SearchController.dart';
import '../../../presentation/home_screen/models/album_model.dart';
import '../../../presentation/home_screen/models/category_model.dart';
import '../../../presentation/home_screen/models/recent_model.dart';
import '../../../presentation/home_screen/models/top_tracks_model.dart';
import '../../../presentation/home_screen/models/user_details_model.dart';

class ApiServices {
  final box = GetStorage();

  Future<void> getAccessToken(String authorizationCode, String redirectUri,
      String clientId, String clientSecret) async {
    final String tokenUrl = ApiList.tokenGen;

    final Map<String, String> requestBody = {
      'grant_type': 'authorization_code',
      'code': authorizationCode,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'client_secret': clientSecret,
    };

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(data);
      final String accessToken = data['access_token'];
      box.write('token', data['access_token']);
      box.write('refreshToken', data['refresh_token']);
      Get.offAllNamed(PageList.bottomNavScreen);
    } else {
      print('Failed to get access token: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> userData() async {
    String token = Constdetails().token;
    final url = ApiList.user;
    try {
      final data = await ApiMethods()
          .get(url: url, headers: {'Authorization': 'Bearer $token'});

      return jsonDecode(data);
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<List<libry.Items>> fetchPlaylists() async {
    final url = ApiList.playList;
    final token = Constdetails().token;
    try {
      final response = await ApiMethods().get(
        url: url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items
          .map((datas) => libry.Items.fromJson(datas as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e);
    }
    return [];
  }

  void startTokenRefreshTimer() {
    Timer? _timer;
    _timer = Timer.periodic(Duration(minutes: 55), (timer) {
      refreshAccessToken();
    });
  }

  Future<String?> refreshAccessToken() async {
    final uri = ApiList.tokenGen;
    final clientId = Constdetails().clientId;
    final clientSecret = Constdetails().clientSecret;
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
    String refreshToken = box.read('refreshToken') ?? '';

    try {
      final response = await ApiMethods().post(
          uri: uri,
          headers: {'Authorization': 'Basic $credentials'},
          body: {'grant_type': 'refresh_token', 'refresh_token': refreshToken});
      final data = jsonDecode(response);
      print(data);
      box.write('token', data['access_token']);
      return data['access_token'];
    } catch (e) {
      print(e);
    }
    return null;
  }

// // Search for similar tracks using the artist and track name
  Future<List<Map<String, dynamic>>?> searchSimilarTracks(
      String trackName) async {
    AudioController audioController = Get.find();
    final token = Constdetails().token;
    try {
      final response = await ApiMethods().get(
          url:
              'https://api.spotify.com/v1/search?q=$trackName&type=track&limit=50',
          headers: {'Authorization': 'Bearer $token'});
      final data = jsonDecode(response);
      List tracks = data['tracks']['items'];
      tracks.shuffle();
      for (var track in tracks) {
        audioController.queueSongs.add({
          'songName': track['name'],
          'artist': track['artists'][0]['name'],
          'imgUrl': track['album']['images'][0]['url'],
        });
      }
      return [];
    } catch (e) {
      print(e);
    }

    return null;
  }

  // Future<PlaylistTrackResponse?> fetchSongList(String id, bool isLiked) async {
  //   final token = Constdetails().token;
  //   final liked = ApiList.liked;
  //   final uri = '${ApiList.baseUrl}/playlists/${id}/tracks';
  //   try {
  //     final data = await ApiMethods().get(
  //         url: isLiked ? liked : uri,
  //         headers: {'Authorization': 'Bearer $token'});
  //     PlaylistTrackResponse list =
  //         PlaylistTrackResponse.fromJson(jsonDecode(data));
  //
  //     return PlaylistTrackResponse.fromJson(jsonDecode(data));
  //   } catch (e, s) {
  //     print(e);
  //     print(s);
  //   }
  //   return null;
  // }

  Future<ArtistSongs?> fetchArtistSongList(String url) async {
    final token = Constdetails().token;

    try {
      final data = await ApiMethods()
          .get(url: url, headers: {'Authorization': 'Bearer $token'});
      return ArtistSongs.fromJson(jsonDecode(data));
    } catch (e, s) {
      print(e);
      print(s);
    }
    return null;
  }

  Future<TopArtist?> fetchArtists() async {
    final url = 'https://api.spotify.com/v1/me/top/artists';
    final token = Constdetails().token;

    try {
      final data = await ApiMethods()
          .get(url: url, headers: {'Authorization': 'Bearer $token'});
      return TopArtist.fromJson(jsonDecode(data));
    } catch (e, s) {
      print(e);
      print(s);
    }
    return null;
  }

  Future<List<sg_list.Item>> fetchSongList({required String? uri}) async {
    print(uri);
    final token = Constdetails().token;
    List<dynamic> allItems = [];
    try {
      while (uri != null) {
        final response = await ApiMethods()
            .get(url: uri, headers: {'Authorization': 'Bearer $token'});
        final data = jsonDecode(response);
        final items = data['items'] as List;
        allItems.addAll(items);
        uri = data['next'];
        // print(nxtUrl);
      }
      return allItems.map((value) => sg_list.Item.fromJson(value)).toList();
    } catch (e, s) {
      print(e);
      print(s);
    }
    return [];
  }

  Future<recent_play?> fetchRecentList() async {
    final token = Constdetails().token;
    String url = ApiList.recent;
    try {
      final data = await ApiMethods()
          .get(url: url, headers: {'Authorization': 'Bearer $token'});
      return recent_play.fromJson(jsonDecode(data));
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<CategoryModel?> fetchCategory() async {
    final token = Constdetails().token;
    try {
      final data = await ApiMethods().get(
          url: ApiList.category, headers: {'Authorization': 'Bearer $token'});
      CategoryModel categories = CategoryModel.fromJson(jsonDecode(data));
      categories.categories!.items!.shuffle();
      return categories;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<TopTracks?> fetchTopTracks() async {
    try {
      final data = await ApiMethods().get(
          url: ApiList.topTracks,
          headers: {'Authorization': 'Bearer ${Constdetails().token}'});
      return TopTracks.fromJson(jsonDecode(data));
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<AlbumList?> fetchAlbums() async {
    try {
      final data = await ApiMethods().get(
          url:
              'https://api.spotify.com/v1/albums?ids=382ObEPsp2rxGrnsizN5TX%2C1A2GTWGtFfWp7KSQTwWOyo%2C2noRn2Aes5aoNVsU6iWThc',
          headers: {'Authorization': 'Bearer ${Constdetails().token}'});
      return AlbumList.fromJson(jsonDecode(data));
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<NewReleases?> fetchNewRelease() async {
    try {
      final data = await ApiMethods().get(
          url: 'https://api.spotify.com/v1/browse/new-releases',
          headers: {'Authorization': 'Bearer ${Constdetails().token}'});
      return NewReleases.fromJson(jsonDecode(data));
    } catch (e) {
      print(e);
    }
    return null;
  }
}
// https://api.spotify.com/v1/me/top/artists
