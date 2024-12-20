import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/routes/PageList.dart';

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
      Get.offAllNamed(PageList.bottomNavScreen);
    } else {
      print('Failed to get access token: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchPlaylists() async {
    final url = 'https://api.spotify.com/v1/me/playlists';
    final token = Constdetails().Token;
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] as List<dynamic>; // Return items directly
    } else {
      print(response.body);
      throw Exception('Failed to load playlists');
    }
  }
}
