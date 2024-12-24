import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Model/library_playlist_model.dart'
    as libry;
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart';
import 'package:spotify_prj/routes/PageList.dart';

import '../../../presentation/home_screen/models/recent_model.dart';

class Apiservices {
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

  Future<List<libry.Items>> fetchPlaylists() async {
    final url = 'https://api.spotify.com/v1/me/playlists';
    final token = Constdetails().Token;

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>; // Extract the 'items' array
      return items
          .map((item) => libry.Items.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      print(response.body);
      throw Exception('Failed to load playlists');
    }
  }

  void startTokenRefreshTimer() {
    Timer? _timer;
    // Set timer to refresh the token every 55 minutes (or slightly less than 3600 seconds)
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      refreshAccessToken();
    });
  }

  Future<String?> refreshAccessToken() async {
    final clientId = '89bef0e798094050aca7a0efdaebef16';
    final clientSecret = 'a2b87de307064a1aa1a072d72c65ed66';
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
    String refreshToken = box.read('refreshToken');
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      box.write('token', data['access_token']);
      return data['access_token'];
    } else {
      print('Error refreshing token: ${response.body}');
      return null;
    }
  }

  Future<PlaylistTrackResponse?> fetchSongList(String id) async {
    final token = Constdetails().Token;

    // final uri = 'https://api.spotify.com/v1/me/tracks';
    final uri = 'https://api.spotify.com/v1/playlists/${id}/tracks';
    final response = await http
        .get(Uri.parse(uri), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      print(response.body);
      final data = jsonDecode(response.body);
      return PlaylistTrackResponse.fromJson(data);
    } else {
      print('status code ${response.statusCode}');
      print(response.body);
    }
    return null;
  }

  Future<recent_play?> fetchRecentList() async {
    final token = Constdetails().Token;
    String url = 'https://api.spotify.com/v1/me/player/recently-played?limit=4';

    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['items'] as List<dynamic>;
      print(items);
      return recent_play.fromJson(data);
    } else {
      print(response.statusCode);
      print(response.body);
    }
    return null;
  }
}
