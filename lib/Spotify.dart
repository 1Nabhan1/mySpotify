import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'HomePage.dart';

class SpotifyLoginWebView extends StatefulWidget {
  final String authorizationUrl;
  final String redirectUri;
  final Function(String) onCodeReceived;

  SpotifyLoginWebView({
    required this.authorizationUrl,
    required this.redirectUri,
    required this.onCodeReceived,
  });

  @override
  _SpotifyLoginWebViewState createState() => _SpotifyLoginWebViewState();
}

class _SpotifyLoginWebViewState extends State<SpotifyLoginWebView> {
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spotify Login')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.authorizationUrl)),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStart: (controller, url) {
          if (url.toString().startsWith(widget.redirectUri)) {
            final Uri responseUri = Uri.parse(url.toString());
            final String? authorizationCode =
                responseUri.queryParameters['code'];

            if (authorizationCode != null) {
              widget.onCodeReceived(authorizationCode);
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
