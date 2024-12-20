import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String accessToken;

  HomePage({required this.accessToken});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String? nowPlayingTitle;
  String? nowPlayingArtist;
  bool isPlaying = false;
  int?
      currentlyPlayingTrackIndex; // Tracks the index of the currently playing song
  List<bool> trackLoadingState = []; // Tracks loading state for each track

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Listen to playback state changes
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });

    // Listen for playback completion
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _playNextTrack();
      }
    });
  }

  Future<void> _playYouTubeAudio(
      String videoId, String title, String artist) async {
    var yt = YoutubeExplode();
    try {
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioStream = manifest.audioOnly.withHighestBitrate();
      if (audioStream != null) {
        final audioUrl = audioStream.url.toString();
        await _audioPlayer.setUrl(audioUrl);
        _audioPlayer.play();
        setState(() {
          nowPlayingTitle = title;
          nowPlayingArtist = artist;
        });
      } else {
        print('No audio stream found for this video.');
      }
    } catch (e) {
      print('Error playing YouTube audio: $e');
    } finally {
      yt.close();
    }
  }

  Future<void> _searchTracks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String apiUrl =
        'https://api.spotify.com/v1/search?q=$query&type=track';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        searchResults = data['tracks']['items'];
        trackLoadingState = List<bool>.filled(
            searchResults.length, false); // Initialize loading state
        isLoading = false;
      });
    } else {
      print('Failed to search tracks: ${response.body}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _playNextTrack() async {
    if (currentlyPlayingTrackIndex == null)
      return; // Return early if no track is playing

    final nextIndex = currentlyPlayingTrackIndex! + 1;
    if (nextIndex < searchResults.length) {
      final nextTrack = searchResults[nextIndex];
      final String query =
          '${nextTrack['name']} ${nextTrack['artists'][0]['name']}';

      // Update the current track index
      setState(() {
        currentlyPlayingTrackIndex = nextIndex; // Update the current index
      });

      // Play the next track
      await _playTrack(query, nextIndex);
    } else {
      // Optionally handle the case when no next track is available
      print('No more tracks to play.');
    }

    return; // Explicit return to satisfy the Future<void> return type
  }

  Future<void> _playTrack(String query, int index) async {
    setState(() {
      trackLoadingState[index] = true; // Mark the track as loading
      currentlyPlayingTrackIndex = index; // Set the current track index
    });

    final String apiUrl =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=AIzaSyAFxowQED_gJYOP4-FlPYRipg0RQ2RPUYU';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['items'].isNotEmpty) {
        final videoId = data['items'][0]['id']['videoId'];
        final trackTitle = data['items'][0]['snippet']['title'];
        final trackArtist = data['items'][0]['snippet']['channelTitle'];
        await _playYouTubeAudio(videoId, trackTitle, trackArtist);
      } else {
        print('No YouTube video found for the track.');
      }
    } else {
      print('Failed to search YouTube: ${response.body}');
    }

    setState(() {
      trackLoadingState[index] = false; // Mark the track as loaded
    });
  }

  Widget _buildNowPlaying() {
    if (nowPlayingTitle == null) return SizedBox();

    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nowPlayingTitle!,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            nowPlayingArtist!,
            style: TextStyle(color: Colors.grey[400], fontSize: 14.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.white,
                ),
                onPressed: () {
                  _playNextTrack(); // Skip to the next track
                },
              ),
              StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _audioPlayer.duration ?? Duration.zero;
                  final positionText = _formatDuration(position);
                  final durationText = _formatDuration(duration);

                  return Expanded(
                    child: Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(positionText,
                                style: TextStyle(color: Colors.white)),
                            Text(durationText,
                                style: TextStyle(color: Colors.white)),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Music App')),
      body: Column(
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
                  () => _searchTracks(query),
                );
              },
            ),
          ),
          isLoading
              ? LinearProgressIndicator()
              : Expanded(
                  child: searchResults.isNotEmpty
                      ? ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final track = searchResults[index];
                            final isCurrentlyPlaying =
                                currentlyPlayingTrackIndex == index;
                            return ListTile(
                              title: Text(track['name']),
                              subtitle: Text(track['artists'][0]['name']),
                              leading: trackLoadingState[index]
                                  ? CircularProgressIndicator() // Show loading indicator for clicked track
                                  : (track['album']['images'].isNotEmpty
                                      ? Image.network(
                                          track['album']['images'][0]['url'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.error_outline);
                                          },
                                        )
                                      : Icon(Icons.music_note)),
                              trailing: isCurrentlyPlaying
                                  ? Icon(Icons.play_arrow, color: Colors.green)
                                  : null,
                              onTap: () {
                                final String query =
                                    '${track['name']} ${track['artists'][0]['name']}';
                                _playTrack(query, index);
                              },
                            );
                          },
                        )
                      : Center(child: Text('No results found.')),
                ),
        ],
      ),
      floatingActionButton: _buildNowPlaying(),
    );
  }

// Helper function to format the duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
