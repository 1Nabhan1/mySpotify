import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:html/parser.dart' as html;
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioController extends GetxController {
  var currentlyPlayingTrackIndex = RxInt(-1);
  var trackLoadingState = <RxBool>[].obs;
  var nowPlayingTitle = ''.obs;
  var nowPlayingArtist = ''.obs;
  var isPlaying = false.obs;
  var imgPly = ''.obs;
  // final AudioPlayer audioPlayer = AudioPlayer();
  var dominantColor = Colors.transparent.obs;
  var textColor = Colors.white.obs;
  final webViewController = Rx<InAppWebViewController?>(null);
  RxDouble currentPlayingTime = 0.0.obs;
  RxDouble totalDuration = 0.0.obs;
  HeadlessInAppWebView? headlessWebView;
  List<dynamic> queueSongs = [].obs;

  Future<void> playYouTubeAudio(String videoId, String title, String artist,
      String img, int currentIndex) async {
    await headlessWebView?.dispose();
    // Create a HeadlessInAppWebView instance
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('https://www.youtube.com/watch?v=$videoId'),
      ),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture:
            false, // Allow autoplay without user interaction
        allowContentAccess: false, // Disable content access for extra security
        allowFileAccess: false, // Disable file access
      ),
      onWebViewCreated: (controller) {
        print("WebView Created");

        // Attach JavaScript handler for playback status
        controller.addJavaScriptHandler(
          handlerName: 'audioPlaying',
          callback: (args) {
            if (args.isNotEmpty && args[0] is bool) {
              isPlaying.value = args[0];
              print("Audio is playing: ${isPlaying.value}");
            }
          },
        );

        // Attach JavaScript handler for current time and duration
        controller.addJavaScriptHandler(
          handlerName: 'audioProgress',
          callback: (args) {
            if (args.isNotEmpty && args.length == 2) {
              final currentTime = args[0];
              final duration = args[1];
              print("Current Time: $currentTime, Total Duration: $duration");
              currentPlayingTime.value = currentTime ?? 0.0;
              totalDuration.value = duration ?? 0.0;
              if (totalDuration.value - currentPlayingTime.value < 15) {
                headlessWebView?.dispose().then(
                  (value) {
                    playNextTrack(currentIndex);
                  },
                );
                // Play the next song
              }
            }
          },
        );
      },
      onLoadStop: (controller, url) async {
        print("Page loaded: $url");

        // Inject JavaScript to autoplay the video and ensure it is not muted
        await controller.evaluateJavascript(source: """
        var video = document.querySelector('video');
        if (video) {
          var playPromise = video.play();
          if (playPromise !== undefined) {
            playPromise.then(() => {
              console.log("Video is playing");
              window.flutter_inappwebview.callHandler('audioPlaying', true);

              // Continuously report the playback progress
              setInterval(() => {
                var currentTime = video.currentTime; // Current playback time
                var duration = video.duration; // Total duration
                window.flutter_inappwebview.callHandler('audioProgress', currentTime, duration);
              }, 1000); // Update every second
            }).catch(error => {
              console.error("Error while trying to play the video:", error);
              window.flutter_inappwebview.callHandler('audioPlaying', false);
            });
          }
          video.muted = false; // Ensure audio is enabled
        } else {
          window.flutter_inappwebview.callHandler('audioPlaying', false);
        }
      """);
        nowPlayingTitle.value = title;
        nowPlayingArtist.value = artist;
        imgPly.value = img;
      },
    );

    try {
      // Start the Headless WebView
      await headlessWebView?.run();
      print("Headless WebView running in background");
    } catch (e) {
      print("Error starting Headless WebView: $e");
      isPlaying.value = false; // Reset to false if there's an error
    }
  }

  // Add songs to the queue
  void addToQueue(String songName, String artist, String imgUrl) {
    queueSongs.add({
      'songName': songName,
      'artist': artist,
      'imgUrl': imgUrl,
    });
    // print("Song added to queue: $songName by $artist");
  }

  Future<void> togglePlayPause() async {
    if (headlessWebView != null) {
      try {
        await headlessWebView!.webViewController?.evaluateJavascript(source: """
        var video = document.querySelector('video');
        if (video) {
          if (video.paused) {
            video.play();
            window.flutter_inappwebview.callHandler('audioPlaying', true);
            console.log("Playback resumed");
          } else {
            video.pause();
            window.flutter_inappwebview.callHandler('audioPlaying', false);
            console.log("Playback paused");
          }
        }
      """);
      } catch (e) {
        print("Error toggling play/pause: $e");
      }
    } else {
      print("No Headless WebView instance available to control playback.");
    }
  }

  double getLuminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    // Applying the luminance formula
    final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    return luminance;
  }

  Future<void> updateDominantColor(String imageUrl) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
      );
      // Set the dominant color (fallback to transparent if null)
      dominantColor.value =
          paletteGenerator.dominantColor?.color ?? Colors.transparent;
      double luminance = getLuminance(dominantColor.value);
      textColor.value = luminance < 0.5 ? Colors.white : Colors.black;
    } catch (e) {
      print('Error extracting color: $e');
      dominantColor.value = Colors.transparent;
    }
  }

  Future<void> getVideoIdFromSearch(int index) async {
    final yt = YoutubeExplode();

    // Ensure there is a valid index in queueSongs
    if (queueSongs.isNotEmpty && index < queueSongs.length) {
      var item = queueSongs[index]; // Fetch the song details from the queue

      // Ensure the song details are valid
      if (item != null && item['songName'] != null && item['artist'] != null) {
        currentlyPlayingTrackIndex.value = index;

        // Search YouTube for the song
        var searchResults = await yt.search.search(item['songName']);

        if (searchResults.isNotEmpty) {
          var firstVideo = searchResults.first;
          print("Video ID: ${firstVideo.id}"); // Print video ID
          await playYouTubeAudio('${firstVideo.id}', item['songName'],
              item['artist'], item['imgUrl'], index);

          // Start tracking playback progress
          // trackProgressChecker(index);
        } else {
          print("No results found for ${item['songName']}.");
        }
      }
    }
  }

  Future<void> playNextTrack(int currentIndex) async {
    await headlessWebView?.dispose().then(
      (value) async {
        print('Next Track');
        int nextIndex = currentIndex + 1;

        // Check if there's another song in the queue
        if (nextIndex < queueSongs.length) {
          await getVideoIdFromSearch(nextIndex);
        } else {
          print("End of the queue.");
        }
      },
    );
  }

  Future<void> playPreviousTrack(int currentIndex) async {
    await headlessWebView?.dispose().then(
      (value) async {
        print('Previous Track');
        int previousIndex = currentIndex - 1;

        // Check if there's a previous song in the queue
        if (previousIndex >= 0 && previousIndex < queueSongs.length) {
          // Update the currently playing index
          currentIndex = previousIndex;

          // Get the song details from the queue
          var previousSong = queueSongs[previousIndex];

          if (previousSong != null) {
            // Play the previous track
            await getVideoIdFromSearch(previousIndex);
          }
        } else {
          print("No previous track available.");
        }
      },
    );
  }

  String formatTime(double timeInSeconds) {
    int minutes = timeInSeconds ~/ 60; // Integer division for minutes
    int seconds = (timeInSeconds % 60).toInt(); // Remainder for seconds
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  // @override
  // void onClose() {
  //   // audioPlayer.dispose();
  //   super.onClose();
  // }
}
