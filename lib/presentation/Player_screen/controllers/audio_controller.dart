import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
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
  RxBool playerLoading = false.obs;

  AudioPlayer _audioPlayer = AudioPlayer();

// Request to keep the app running in the background
  Future<void> enableBackgroundMode() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Playing Music",
      notificationText: "Music is playing in the background",
      // notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'),
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);

    // Ensure that background mode is enabled
    bool success = await FlutterBackground.enableBackgroundExecution();
    if (success) {
      print("Background mode enabled");
    } else {
      print("Failed to enable background mode");
    }
  }

  Future<void> playYouTubeAudio(String videoId, String title, String artist,
      String img, int currentIndex) async {
    // playerLoading.value = true;

    final yt = YoutubeExplode();

    try {
      // Get the video information from YouTube
      var video = await yt.videos.get(videoId);
      var streamManifest = await yt.videos.streamsClient.getManifest(videoId);

      // Find the first audio stream (it may have different container/codec types)
      var audioStream = streamManifest.audioOnly.firstWhere(
          (s) => s.container.name == 'mp4' || s.container.name == 'webm',
          orElse: () => throw Exception("No compatible audio stream found"));
      print('audioStream.url.toString()');
      print(audioStream.url.toString());
      // Play the audio stream
      await _audioPlayer.setUrl(audioStream.url.toString());
      isPlaying.value = true;
      // Update track details
      nowPlayingTitle.value = title;
      nowPlayingArtist.value = artist;
      imgPly.value = img;

      // Track playback progress
      _audioPlayer.positionStream.listen((position) {
        currentPlayingTime.value = position.inSeconds.toDouble();
        // print(position);
      });
      _audioPlayer.durationStream.listen((duration) {
        totalDuration.value = duration?.inSeconds.toDouble() ?? 0.0;
      });
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          playNextTrack(currentIndex);
        }
      });
      playerLoading.value = false;
      // Start playback
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing YouTube audio: $e");
      isPlaying.value = false;
    } finally {
      playerLoading.value = false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    enableBackgroundMode();
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
    try {
      if (_audioPlayer.playing) {
        // If the audio is currently playing, pause it
        await _audioPlayer.pause();
        isPlaying.value = false; // Update the play/pause state
        print("Playback paused");
      } else {
        // If the audio is paused, play it
        await _audioPlayer.play();
        isPlaying.value = true; // Update the play/pause state
        print("Playback resumed");
      }
    } catch (e) {
      print("Error toggling play/pause: $e");
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
        var searchResults =
            // await yt.search.search("${item['songName']}");
            await yt.search.search("${item['songName']},${item['artist']}");

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
    playerLoading.value = true;
    print('Next Track');
    int nextIndex = currentIndex + 1;

    // Check if there's another song in the queue
    if (nextIndex < queueSongs.length) {
      await getVideoIdFromSearch(nextIndex);
    } else {
      print("End of the queue.");
      playerLoading.value = false;
    }
  }

  Future<void> playPreviousTrack(int currentIndex) async {
    playerLoading.value = true;
    print('Previous Track');
    int previousIndex = currentIndex - 1;

    // Check if there's another song in the queue
    if (previousIndex >= 0 && previousIndex < queueSongs.length) {
      await getVideoIdFromSearch(previousIndex);
    } else {
      print("End of the queue.");
      playerLoading.value = false;
    }
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
