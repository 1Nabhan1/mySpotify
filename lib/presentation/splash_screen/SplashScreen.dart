import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/splash_screen/controller/SplashController.dart';

class Splashscreen extends StatelessWidget {
  Splashscreen({super.key});
  final SplashController splashcontroller = Get.put(SplashController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'Assets/HD-wallpaper-spotify-app-black-and-white-green-logo-logos-music-spotify-music-stream-streaming.jpg',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }
}
