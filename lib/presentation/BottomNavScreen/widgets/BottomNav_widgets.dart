import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:spotify_prj/main.dart';
import 'package:spotify_prj/routes/PageList.dart';

import '../../Player_screen/controllers/audio_controller.dart';
import '../../Player_screen/player_screen.dart';

class BottomNavWidgets {
  Widget musicPlayer(AudioController audioController) {
    return Obx(
      () => audioController.nowPlayingTitle.value.isEmpty
          ? SizedBox.shrink()
          : GestureDetector(
              onTap: () {
                // Get.toNamed(PageList.playerScreen);
                Get.to(
                  () =>
                      PlayerScreen(), // Replace with your actual screen widget
                  transition:
                      Transition.downToUp, // Predefined transition from GetX
                  duration: Duration(milliseconds: 300), // Optional duration
                );
              },
              child: Container(
                color: audioController.dominantColor.value,
                // padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                width: 50,
                                child: Image.network(
                                  audioController.imgPly.value,
                                  height: 50,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      // Extract dominant color once the image is loaded
                                      audioController.updateDominantColor(
                                          audioController.imgPly.value);
                                    }
                                    return child;
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.error,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    audioController.nowPlayingTitle.value,
                                    style: TextStyle(
                                        color: audioController.textColor.value,
                                        fontSize: 16.0),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    audioController.nowPlayingArtist.value,
                                    style: TextStyle(
                                        color: audioController.textColor.value,
                                        fontSize: 12.0),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: audioController.playerLoading.value
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        color: audioController.textColor.value,
                                      ),
                                    )
                                  : Icon(
                                      audioController.isPlaying.value
                                          ? CupertinoIcons.pause_circle
                                          : CupertinoIcons.play_circle,
                                      color: audioController.textColor.value,
                                    ),
                              onPressed: audioController.playerLoading.value
                                  ? null
                                  : () {
                                      if (audioController.isPlaying.value) {
                                        audioController.togglePlayPause();
                                        audioController.isPlaying.value = false;
                                      } else {
                                        audioController.togglePlayPause();
                                        audioController.isPlaying.value = true;
                                      }
                                    },
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.forward_end,
                                color: audioController.textColor.value,
                              ),
                              onPressed: audioController.playerLoading.value
                                  ? null
                                  : () {
                                      audioController.playNextTrack(
                                          audioController
                                              .currentlyPlayingTrackIndex
                                              .value);
                                    },
                            ),
                          ],
                        )
                      ],
                    ),
                    LinearProgressIndicator(
                      value: (audioController.currentPlayingTime.value /
                              audioController.totalDuration.value)
                          .clamp(0.0, 1.0),
                      minHeight: 2, // A  value between 0.0 and 1.0
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
