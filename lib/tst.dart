import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  final String accessToken;

  HomePage({required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Music App')),
      body: GetBuilder<HomeController>(
        init: HomeController(accessToken),
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search for a song',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) {
                    Future.delayed(
                      Duration(seconds: 1),
                      () => controller.searchTracks(query),
                    );
                  },
                ),
              ),
              controller.isLoading
                  ? LinearProgressIndicator()
                  : Expanded(
                      child: controller.searchResults.isNotEmpty
                          ? ListView.builder(
                              itemCount: controller.searchResults.length,
                              itemBuilder: (context, index) {
                                final track = controller.searchResults[index];
                                final isCurrentlyPlaying =
                                    controller.currentlyPlayingTrackIndex ==
                                        index;
                                return ListTile(
                                  title: Text(track['name']),
                                  subtitle: Text(track['artists'][0]['name']),
                                  leading: controller.trackLoadingState[index]
                                      ? CircularProgressIndicator() // Show loading indicator for clicked track
                                      : (track['album']['images'].isNotEmpty
                                          ? Image.network(
                                              track['album']['images'][0]
                                                  ['url'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                    Icons.error_outline);
                                              },
                                            )
                                          : Icon(Icons.music_note)),
                                  trailing: isCurrentlyPlaying
                                      ? Icon(Icons.play_arrow,
                                          color: Colors.green)
                                      : null,
                                  onTap: () {
                                    final String query =
                                        '${track['name']} ${track['artists'][0]['name']}';
                                    controller.playTrack(query, index);
                                  },
                                );
                              },
                            )
                          : Center(child: Text('No results found.')),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: GetBuilder<HomeController>(
        builder: (controller) {
          return controller.nowPlayingTitle == null
              ? SizedBox()
              : Container(
                  color: Colors.grey[900],
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.nowPlayingTitle!,
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        controller.nowPlayingArtist!,
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 14.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              controller.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (controller.isPlaying) {
                                controller.audioPlayer.pause();
                              } else {
                                controller.audioPlayer.play();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              controller
                                  .playNextTrack(); // Skip to the next track
                            },
                          ),
                          StreamBuilder<Duration>(
                            stream: controller.audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final duration =
                                  controller.audioPlayer.duration ??
                                      Duration.zero;
                              final positionText =
                                  controller.formatDuration(position);
                              final durationText =
                                  controller.formatDuration(duration);

                              return Expanded(
                                child: Column(
                                  children: [
                                    Slider(
                                      value: position.inSeconds.toDouble(),
                                      max: duration.inSeconds.toDouble(),
                                      onChanged: (value) {
                                        controller.audioPlayer.seek(
                                            Duration(seconds: value.toInt()));
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(positionText,
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Text(durationText,
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

class HomeController extends GetxController {
  final String accessToken;
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String? nowPlayingTitle;
  String? nowPlayingArtist;
  bool isPlaying = false;
  int? currentlyPlayingTrackIndex;
  List<bool> trackLoadingState = [];
  final AudioPlayer audioPlayer = AudioPlayer();

  HomeController(this.accessToken);

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
        'Authorization': 'Bearer $accessToken',
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
