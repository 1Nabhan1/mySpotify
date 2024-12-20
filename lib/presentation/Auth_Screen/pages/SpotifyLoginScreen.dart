import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Spotifyloginscreen extends StatelessWidget {
  Spotifyloginscreen(
      {super.key,
      required this.authorizationUrl,
      required this.redirectUri,
      required this.onCodeReceived});
  final String authorizationUrl;
  final String redirectUri;
  final Function(String) onCodeReceived;
  late InAppWebViewController webViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(authorizationUrl)),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          if (url.toString().startsWith(redirectUri)) {
            final Uri responseUri = Uri.parse(url.toString());
            final String? authorizationCode =
                responseUri.queryParameters['code'];

            if (authorizationCode != null) {
              onCodeReceived(authorizationCode);
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
