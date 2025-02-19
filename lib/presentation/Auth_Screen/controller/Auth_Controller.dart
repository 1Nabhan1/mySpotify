import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/Auth_Screen/pages/SpotifyLoginScreen.dart';

class AuthController extends GetxController {
  final String clientId = Constdetails().clientId;
  final String clientSecret = Constdetails().clientSecret;
  final String redirectUri = 'myspotify://callback';
  final GetStorage box = GetStorage();
  late InAppWebViewController webViewController;

  Future<void> authenticateWithSpotify() async {
    final String authorizationUrl =
        'https://accounts.spotify.com/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&scope=user-read-private user-read-email playlist-read-private user-modify-playback-state user-read-playback-state user-library-read user-read-recently-played user-top-read user-library-modify playlist-modify-public playlist-modify-private';
    Get.to(Spotifyloginscreen(
      authorizationUrl: authorizationUrl,
      redirectUri: redirectUri,
      onCodeReceived: (authorizationCode) {
        ApiServices().getAccessToken(
            authorizationCode, redirectUri, clientId, clientSecret);
        webViewController.clearSslPreferences();
        webViewController.clearHistory();
        webViewController.clearFormData();
        webViewController.clearCache();
      },
    ));
  }
}
