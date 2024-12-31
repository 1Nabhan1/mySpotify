import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'SearchController/SearchController.dart';

class Searchscreen extends StatelessWidget {
  const Searchscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GetBuilder<Searchcontroller>(
          init: Searchcontroller(),
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
                                    title: Text(
                                      track['name'],
                                      style: TextStyle(color: Colors.white),
                                    ),
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
      ),
      bottomSheet: BottomSheet(
        onClosing: () {},
        builder: (context) {
          return GetBuilder<Searchcontroller>(
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            controller.nowPlayingArtist!,
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14.0),
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
                                  final position =
                                      snapshot.data ?? Duration.zero;
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
                                                Duration(
                                                    seconds: value.toInt()));
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(positionText,
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            Text(durationText,
                                                style: TextStyle(
                                                    color: Colors.white)),
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
          );
        },
      ),
    );
  }
}
