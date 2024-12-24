import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/routes/AppRoutes.dart';
import 'package:spotify_prj/routes/PageList.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotify_prj/tst.dart';
import 'AuthPage.dart';
import 'Spotify.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = Apiservices();
  apiService.startTokenRefreshTimer();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: 'My Spotify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        getPages: Approutes.pages,
        initialRoute: PageList.splashScreen,
        // home: Tst(),
      ),
    );
  }
}
