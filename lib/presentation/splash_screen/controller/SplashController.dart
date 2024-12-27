import 'package:get/get.dart';
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/routes/PageList.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Navigate();
  }

  void Navigate() {
    final constDetails = Constdetails();
    Future.delayed(
      Duration(seconds: 3),
      () {
        if (constDetails.token.isNotEmpty && constDetails.token != null) {
          Get.offAllNamed(PageList.bottomNavScreen);
        } else {
          Get.offAllNamed(PageList.authScreen);
        }
      },
    );
  }
}
