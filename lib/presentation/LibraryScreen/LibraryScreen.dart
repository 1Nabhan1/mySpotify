import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Controller/LibraryController.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Model/library_playlist_model.dart';
import 'package:spotify_prj/routes/PageList.dart';

import '../song_list_screen/song_list_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LibraryController librarycontroller = Get.put(LibraryController());
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Items>>(
        future: librarycontroller.futurePlaylists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final playlists = snapshot.data!;
            return GridView.builder(
              itemCount: playlists.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisExtent: 200),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final name = playlist.name;
                final description = playlist.description ?? '';
                final images = playlist.images![0].url;
                final imageUrl = images != null
                    ? images
                    : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS20We-b2vHTRTj7VuyEe7F2jP_JvfnwzHPLg&s';

                return GestureDetector(
                  onTap: () {
                    // Apiservices().refreshAccessToken();
                    Get.toNamed(PageList.songListScreen,
                        arguments: {'id': '${playlist.id}'});
                    print(Constdetails().Token);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 100,
                                child: Image.network(
                                  imageUrl,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error_outline);
                                  },
                                )),
                            Text(
                              name!,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              description,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text('No data available.'));
        },
      ),
    );
  }
}
