import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/audio_controller.dart';

class PlayerWidgets {
  Widget playDetails({required AudioController audioController}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35.0.w, vertical: 30.h),
          child: SizedBox(
            width: double.infinity,
            height: 280.h,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.network(
                  audioController.imgPly.value,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.error));
                  },
                )),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 35.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                audioController.nowPlayingTitle.value,
                style: TextStyle(
                    color: audioController.textColor.value,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                audioController.nowPlayingArtist.value,
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget controlWidget(
      {required AudioController audioController,
      required BuildContext context}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0.h, horizontal: 8),
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                      trackHeight: 1),
                  child: Slider(
                    value: audioController.currentPlayingTime!.value,
                    min: 0.0,
                    inactiveColor:
                        audioController.textColor.value.withOpacity(.1),
                    // Colors.transparent.withOpacity(.5),
                    max: audioController.totalDuration!.value,
                    secondaryActiveColor: audioController.textColor.value,
                    activeColor: audioController.textColor.value,
                    onChanged: (value) {
                      // Update the slider's value without seeking the audio
                      audioController.currentPlayingTime!.value = value;
                    },
                    onChangeStart: (value) {
                      // // Optional: Pause the audio while dragging the slider for better performance
                      // audioController.headlessWebView?.webViewController
                      //     ?.evaluateJavascript(
                      //   source:
                      //       "var video = document.querySelector('video'); if (video) video.pause();",
                      // );
                    },
                    onChangeEnd: (value) {
                      // Seek the audio only when the user releases the slider
                      // audioController.headlessWebView?.webViewController
                      //     ?.evaluateJavascript(
                      //   source:
                      //       "var video = document.querySelector('video'); if (video) video.currentTime = $value; video.play();",
                      // );
                      // // Resume playback if needed
                      // audioController.isPlaying.value = true;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      audioController.formatTime(
                          audioController.currentPlayingTime!.value),
                      style: TextStyle(color: audioController.textColor.value),
                    ),
                    Text(
                        audioController
                            .formatTime(audioController.totalDuration!.value),
                        style:
                            TextStyle(color: audioController.textColor.value)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: audioController.playerLoading.value
                  ? null
                  : () {
                      audioController.playPreviousTrack(
                          audioController.currentlyPlayingTrackIndex.value);
                    },
              child: Icon(
                CupertinoIcons.backward_end,
                color: audioController.textColor.value,
              ),
            ),
            GestureDetector(
              onTap: audioController.playerLoading.value
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
              child: CircleAvatar(
                backgroundColor: audioController.textColor.value,
                radius: 30.r,
                child: audioController.playerLoading.value
                    ? CircularProgressIndicator(
                        strokeWidth: 1,
                        color: audioController.dominantColor.value,
                      )
                    : Icon(
                        audioController.isPlaying.value
                            ? CupertinoIcons.pause
                            : CupertinoIcons.play,
                        color: audioController.dominantColor.value,
                      ),
              ),
            ),
            GestureDetector(
              onTap: audioController.playerLoading.value
                  ? null
                  : () {
                      audioController.playNextTrack(
                          audioController.currentlyPlayingTrackIndex.value);
                    },
              child: Icon(
                CupertinoIcons.forward_end,
                color: audioController.textColor.value,
              ),
            )
          ],
        )
      ],
    );
  }
}
