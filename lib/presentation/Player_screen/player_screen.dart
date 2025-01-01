import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/main.dart';
import 'package:spotify_prj/presentation/Player_screen/controllers/audio_controller.dart';
import 'package:spotify_prj/presentation/Player_screen/widgets/player_widgets.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AudioController audioController = Get.find();
    return Obx(
      () => Scaffold(
        backgroundColor: audioController.dominantColor.value,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        CupertinoIcons.chevron_down,
                        color: audioController.textColor.value,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              PlayerWidgets().playDetails(audioController: audioController),
              PlayerWidgets().controlWidget(
                  audioController: audioController, context: context),
            ],
          ),
        )),
      ),
    );
  }
}
