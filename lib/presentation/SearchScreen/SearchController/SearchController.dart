import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Searchcontroller extends GetxController {
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String? nowPlayingTitle;
  String? nowPlayingArtist;
  bool isPlaying = false;
  int? currentlyPlayingTrackIndex;
  List<bool> trackLoadingState = [];
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();

    // Listen to playback state changes
    audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      update();
    });

    // Listen for playback completion
    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNextTrack();
      }
    });
  }

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

  Future<void> searchTracks(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      update();
      return;
    }

    isLoading = true;
    update();

    final String apiUrl =
        'https://api.spotify.com/v1/search?q=$query&type=track';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${Constdetails().token}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      searchResults = data['tracks']['items'];
      trackLoadingState = List<bool>.filled(
          searchResults.length, false); // Initialize loading state
      isLoading = false;
      update();
    } else {
      print('Failed to search tracks: ${response.body}');
      isLoading = false;
      update();
    }
  }

  Future<void> playNextTrack() async {
    if (currentlyPlayingTrackIndex == null)
      return; // Return early if no track is playing

    final nextIndex = currentlyPlayingTrackIndex! + 1;
    if (nextIndex < searchResults.length) {
      final nextTrack = searchResults[nextIndex];
      final String query =
          '${nextTrack['name']} ${nextTrack['artists'][0]['name']}';

      currentlyPlayingTrackIndex = nextIndex;
      update();

      await playTrack(query, nextIndex);
    } else {
      // Optionally handle the case when no next track is available
      print('No more tracks to play.');
    }
  }

  Future<void> playTrack(String query, int index) async {
    trackLoadingState[index] = true;
    currentlyPlayingTrackIndex = index;
    update();

    final String apiUrl =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=AIzaSyAFxowQED_gJYOP4-FlPYRipg0RQ2RPUYU';

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

    trackLoadingState[index] = false;
    update();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
