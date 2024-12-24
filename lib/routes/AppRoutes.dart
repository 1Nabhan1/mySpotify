import 'package:get/get.dart';
import 'package:spotify_prj/main.dart';
import 'package:spotify_prj/presentation/Auth_Screen/pages/Auth_Screen.dart';
import 'package:spotify_prj/presentation/Auth_Screen/controller/Auth_Controller.dart';
import 'package:spotify_prj/presentation/BottomNavScreen/BottomNavScreen.dart';
import 'package:spotify_prj/presentation/home_screen/HomePage.dart';
import 'package:spotify_prj/presentation/song_list_screen/song_list_screen.dart';
import 'package:spotify_prj/presentation/splash_screen/SplashScreen.dart';
import 'package:spotify_prj/routes/PageList.dart';

class Approutes {
  static var pages = [
    GetPage(
      name: PageList.splashScreen,
      page: () => Splashscreen(),
    ),
    GetPage(
      name: PageList.authScreen,
      page: () => AuthScreen(),
    ),
    GetPage(
      name: PageList.bottomNavScreen,
      page: () => Bottomnavscreen(),
    ),
    GetPage(
      name: PageList.songListScreen,
      page: () => SongListScreen(),
    ),
  ];
}
