import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/Auth_Screen/pages/SpotifyLoginScreen.dart';

class AuthController extends GetxController {
  final String clientId = '89bef0e798094050aca7a0efdaebef16';
  final String clientSecret = 'a2b87de307064a1aa1a072d72c65ed66';
  final String redirectUri = 'myspotify://callback';
  final GetStorage box = GetStorage();
  Future<void> authenticateWithSpotify() async {
    final String authorizationUrl =
        'https://accounts.spotify.com/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&scope=user-read-private user-read-email playlist-read-private user-modify-playback-state user-read-playback-state user-library-read user-read-recently-played';
    Get.to(Spotifyloginscreen(
      authorizationUrl: authorizationUrl,
      redirectUri: redirectUri,
      onCodeReceived: (authorizationCode) {
        Apiservices().getAccessToken(
            authorizationCode, redirectUri, clientId, clientSecret);
      },
    ));
  }
}
