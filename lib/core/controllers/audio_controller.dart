import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioController extends GetxController {
  int? currentlyPlayingTrackIndex;
  List<bool> trackLoadingState = [];
  // bool isLoading = false;
  String? nowPlayingTitle;
  String? nowPlayingArtist;
  final AudioPlayer audioPlayer = AudioPlayer();
  Future<void> playYouTubeAudio(
      String videoId, String title, String artist) async {
    var yt = YoutubeExplode();
    try {
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioStream = manifest.audioOnly.withHighestBitrate();
      if (audioStream != null) {
        final audioUrl = audioStream.url.toString();
        await audioPlayer.setUrl(audioUrl);
        audioPlayer.play();
        nowPlayingTitle = title;
        nowPlayingArtist = artist;
        update();
      } else {
        print('No audio stream found for this video.');
      }
    } catch (e) {
      print('Error playing YouTube audio: $e');
    } finally {
      yt.close();
    }
  }

  Future<void> playTrack(String query, int index) async {
    // Ensure the list has enough elements to accommodate the index
    if (trackLoadingState.length <= index) {
      trackLoadingState.addAll(
          List.generate(index - trackLoadingState.length + 1, (_) => false));
    }

    // Mark the track as loading
    trackLoadingState[index] = true;
    currentlyPlayingTrackIndex = index;
    update();

    final String apiUrl =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=AIzaSyAFxowQED_gJYOP4-FlPYRipg0RQ2RPUYU';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['items'].isNotEmpty) {
          final videoId = data['items'][0]['id']['videoId'];
          final trackTitle = data['items'][0]['snippet']['title'];
          final trackArtist = data['items'][0]['snippet']['channelTitle'];
          await playYouTubeAudio(videoId, trackTitle, trackArtist);
        } else {
          print('No YouTube video found for the track.');
        }
      } else {
        print('Failed to search YouTube: ${response.body}');
      }
    } catch (e) {
      print('Error fetching YouTube track: $e');
    }

    // Mark the track as not loading
    trackLoadingState[index] = false;
    update();
  }
}
