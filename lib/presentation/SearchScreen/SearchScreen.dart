import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Player_screen/controllers/audio_controller.dart';
import 'SearchController/SearchController.dart';

class Searchscreen extends StatelessWidget {
  const Searchscreen({super.key});

  @override
  Widget build(BuildContext context) {
    AudioController audioController = Get.find();
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
                                      // final String query =
                                      //     '${track['name']} ${track['artists'][0]['name']}';
                                      // controller.playTrack(query, index);
                                      // audioController.getVideoIdFromSearch(
                                      //     query,
                                      //     index,
                                      //     track['album']['images'][0]['url'],
                                      //     track['artists'][0]['name']);
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
    );
  }
}
