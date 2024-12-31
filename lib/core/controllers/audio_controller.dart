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

  Future<void> playYouTubeAudio(
      String videoId, String title, String artist, String img) async {
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
              currentPlayingTime.value = currentTime;
              totalDuration.value = duration;
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

  Future<void> getVideoIdFromSearch(
      String query, int index, String imgUrl, String trackArtist) async {
    final yt = YoutubeExplode();
    if (trackLoadingState.length <= index) {
      trackLoadingState.addAll(List.generate(
          index - trackLoadingState.length + 1, (_) => false.obs));
    }

    // Mark the track as loading
    trackLoadingState[index].value = true;
    currentlyPlayingTrackIndex.value = index;
    // Search YouTube for the query
    var searchResults = await yt.search.getVideos(query);

    // If there are results, get the first video
    if (searchResults.isNotEmpty) {
      var firstVideo = searchResults.first;
      print("Video ID: ${firstVideo.id}"); // Print video ID
      await playYouTubeAudio('${firstVideo.id}', query, trackArtist, imgUrl);
      // You can now use this video ID to play the video or extract other details
    } else {
      print("No results found.");
    }
  }

  // Future<void> playTrack(String query, int index, String imgUrl) async {
  //   // print(query);
  //   // Ensure the list can accommodate the requested index
  //   if (trackLoadingState.length <= index) {
  //     trackLoadingState.addAll(List.generate(
  //         index - trackLoadingState.length + 1, (_) => false.obs));
  //   }
  //
  //   // Mark the track as loading
  //   trackLoadingState[index].value = true;
  //   currentlyPlayingTrackIndex.value = index;
  //
  //   // Replace this with a secure method to manage the API key
  //   const String apiKey = 'AIzaSyAFxowQED_gJYOP4-FlPYRipg0RQ2RPUYU';
  //   final String apiUrl =
  //       'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$apiKey';
  //
  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       if (data['items'].isNotEmpty) {
  //         final videoId = data['items'][0]['id']['videoId'];
  //         final trackTitle = data['items'][0]['snippet']['title'];
  //         final trackArtist = data['items'][0]['snippet']['channelTitle'];
  //         await playYouTubeAudio(videoId, trackTitle, trackArtist, imgUrl);
  //         // await playYouTubeAudio(
  //         //   videoId,
  //         // );
  //       } else {
  //         print('No YouTube video found for the track.');
  //       }
  //     } else {
  //       print('Failed to search YouTube: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error fetching YouTube track: $e');
  //   } finally {
  //     // Mark the track as not loading
  //     trackLoadingState[index].value = false;
  //   }
  // }

  String formatTime(double timeInSeconds) {
    int minutes = timeInSeconds ~/ 60; // Integer division for minutes
    int seconds = (timeInSeconds % 60).toInt(); // Remainder for seconds
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void onClose() {
    // audioPlayer.dispose();
    super.onClose();
  }
}
