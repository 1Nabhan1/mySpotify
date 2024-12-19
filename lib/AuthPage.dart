import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HomePage.dart';
import 'Spotify.dart';

class SpotifyAuthPage extends StatefulWidget {
  @override
  _SpotifyAuthPageState createState() => _SpotifyAuthPageState();
}

class _SpotifyAuthPageState extends State<SpotifyAuthPage> {
  final String clientId = '89bef0e798094050aca7a0efdaebef16';
  final String clientSecret = 'a2b87de307064a1aa1a072d72c65ed66';
  final String redirectUri = 'custom://callback';

  Future<void> _authenticateWithSpotify() async {
    final String authorizationUrl =
        'https://accounts.spotify.com/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&scope=user-read-private user-read-email playlist-read-private user-modify-playback-state user-read-playback-state';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpotifyLoginWebView(
          authorizationUrl: authorizationUrl,
          redirectUri: redirectUri,
          onCodeReceived: (authorizationCode) {
            _getAccessToken(authorizationCode);
          },
        ),
      ),
    );
  }

  Future<void> _getAccessToken(String authorizationCode) async {
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
      final String accessToken = data['access_token'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(accessToken: accessToken),
        ),
      );
    } else {
      print('Failed to get access token: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spotify Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticateWithSpotify,
          child: Text('Log in to Spotify'),
        ),
      ),
    );
  }
}