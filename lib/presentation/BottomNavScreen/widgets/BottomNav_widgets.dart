import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:spotify_prj/core/controllers/audio_controller.dart';
import 'package:spotify_prj/main.dart';

class BottomNavWidgets {
  Widget musicPlayer(AudioController audioController) {
    return Obx(
      () => audioController.nowPlayingTitle.value.isEmpty
          ? SizedBox.shrink()
          : Container(
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
                            ),
                          ),
                          SizedBox(width: 200.w,
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
                            icon: Icon(
                              audioController.isPlaying.value
                                  ? CupertinoIcons.pause_circle
                                  : CupertinoIcons.play_circle,
                              color: audioController.textColor.value,
                            ),
                            onPressed: () {
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
                            onPressed: () {
                              // Implement playNextTrack() logic if applicable
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
    );
  }
}
