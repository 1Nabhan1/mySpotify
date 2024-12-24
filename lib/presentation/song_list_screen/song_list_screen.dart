import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart';

import 'controller/song_list_controller.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SongListController controller = Get.put(SongListController());
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<PlaylistTrackResponse?>(
        future: controller.songList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;

            return ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: data!.items.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final items = data.items[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      items.track.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      items.track.artists
                          .take(2)
                          .map((names) => names.name)
                          .join(','),
                      style: TextStyle(color: Colors.grey),
                    ),
                    leading: Image.network(
                      items.track.album.images[0].url,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error_outline);
                      },
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text('Something Went Wrong'),
            );
          } else {
            return Center(child: Text('No Data'));
          }
        },
      ),
    );
  }
}
