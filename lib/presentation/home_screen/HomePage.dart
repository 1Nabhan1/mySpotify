import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/main.dart';
import 'package:spotify_prj/presentation/home_screen/controller/home_controller.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/home_widgets.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController());
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 50.h),
            child: HomeWidgets().customAppbar()),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              HomeWidgets().categorised(controller: controller),
              HomeWidgets().recentSection(controller: controller),
              HomeWidgets().topTrack(controller: controller),
              HomeWidgets().newRelease(controller: controller),
              HomeWidgets().albums(controller: controller),
            ],
          ),
        ));
  }
}
