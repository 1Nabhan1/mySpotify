import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/Auth_Screen/controller/Auth_Controller.dart';

class Spotifyloginscreen extends StatelessWidget {
  Spotifyloginscreen(
      {super.key,
      required this.authorizationUrl,
      required this.redirectUri,
      required this.onCodeReceived});
  final String authorizationUrl;
  final String redirectUri;
  final Function(String) onCodeReceived;

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return Scaffold(
      backgroundColor: Colors.black,
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(authorizationUrl)),
        onWebViewCreated: (controller) {
          authController.webViewController = controller;
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
