import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/core/constants/api_methods.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Model/library_playlist_model.dart'
    as libry;
import 'package:spotify_prj/presentation/home_screen/controller/home_controller.dart';
import 'package:spotify_prj/presentation/home_screen/models/new_releases.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart';
import 'package:spotify_prj/routes/PageList.dart';

import '../../../presentation/home_screen/models/album_model.dart';
import '../../../presentation/home_screen/models/category_model.dart';
import '../../../presentation/home_screen/models/recent_model.dart';
import '../../../presentation/home_screen/models/top_tracks_model.dart';
import '../../../presentation/home_screen/models/user_details_model.dart';

class ApiServices {
  final box = GetStorage();

  Future<void> getAccessToken(String authorizationCode, String redirectUri,
      String clientId, String clientSecret) async {
    final String tokenUrl = 'https://accounts.spotify.com/api/token';

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

  // Future<userDetails?> fetchUserDetail() async {
  //   String token = Constdetails().token;
  //   final url = 'https://api.spotify.com/v1/me';
  //   try {
  //     final data = await ApiMethods()
  //         .get(url: url, headers: {'Authorization': 'Bearer $token'});
  //     return userDetails.fromJson(jsonDecode(data));
  //   } catch (e) {
  //     print(e);
  //   }
  //   return null;
  // }

  Future<Map<String, dynamic>> userData() async {
    String token = Constdetails().token;
    final url = 'https://api.spotify.com/v1/me';
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
    final url = 'https://api.spotify.com/v1/me/playlists';
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
    final uri = 'https://accounts.spotify.com/api/token';
    final clientId = Constdetails().clientId;
    final clientSecret = Constdetails().clientSecret;
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
    String refreshToken = box.read('refreshToken');

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

  Future<PlaylistTrackResponse?> fetchSongList(String id) async {
    final token = Constdetails().token;

    final uri = 'https://api.spotify.com/v1/playlists/${id}/tracks';
    try {
      final data = await ApiMethods()
          .get(url: uri, headers: {'Authorization': 'Bearer $token'});
      return PlaylistTrackResponse.fromJson(jsonDecode(data));
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<recent_play?> fetchRecentList() async {
    final token = Constdetails().token;
    String url = 'https://api.spotify.com/v1/me/player/recently-played';
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
          url: 'https://api.spotify.com/v1/browse/categories',
          headers: {'Authorization': 'Bearer $token'});
      return CategoryModel.fromJson(jsonDecode(data));
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<TopTracks?> fetchTopTracks() async {
    try {
      final data = await ApiMethods().get(
          url: 'https://api.spotify.com/v1/me/top/tracks',
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
