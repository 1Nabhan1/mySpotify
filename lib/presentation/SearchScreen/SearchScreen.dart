import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiList/Apilist.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';

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
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      labelText: 'Search for a song',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      Future.delayed(
                        Duration(seconds: 1),
                        () => controller.search(query: query),
                      );
                    },
                    focusNode: audioController.searchNode,
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
                                    leading:
                                        (track['album']['images'].isNotEmpty
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
                                      controller.trackLoadingState[index] =
                                          true;
                                      audioController.queueSongs.clear();
                                      audioController.addToQueue(
                                        track['name'],
                                        track['artists'][0]['name'],
                                        track['album']['images'][0]['url'],
                                      );
                                      audioController.getVideoIdFromSearch(0);
                                      ApiServices().searchSimilarTracks(
                                        track['name'],
                                      );
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
