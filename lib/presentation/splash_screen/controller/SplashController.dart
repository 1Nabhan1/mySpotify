import 'package:get/get.dart';
import 'package:spotify_prj/routes/PageList.dart';

class Splashcontroller extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Navigate();
  }

  void Navigate() {
    Future.delayed(
      Duration(seconds: 3),
      () {
        Get.offAllNamed(PageList.authScreen);
      },
    );
  }
}
