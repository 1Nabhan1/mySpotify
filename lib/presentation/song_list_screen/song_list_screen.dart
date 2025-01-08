import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/BottomNavScreen/widgets/BottomNav_widgets.dart';
import 'package:spotify_prj/presentation/Player_screen/controllers/audio_controller.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/custom_future_builder.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart';

import 'Widgets/song_list_screen_widgets.dart';
import 'controller/song_list_controller.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SongListController controller = Get.put(SongListController());
    AudioController audioController = Get.find();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SongListScreenWidgets().songDetails(controller),
            controller.arguments['isArtist']
                ? SongListScreenWidgets().artistSongList(
                    controller: controller, audioController: audioController)
                : SongListScreenWidgets().libLik(
                    controller: controller, audioController: audioController),
            SizedBox(
              height: 40.h,
            )
          ],
        ),
      ),
      bottomSheet: BottomNavWidgets().musicPlayer(audioController),
    );
  }
}
