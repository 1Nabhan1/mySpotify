import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/BottomNavScreen/widgets/BottomNav_widgets.dart';
import 'package:spotify_prj/presentation/Player_screen/controllers/audio_controller.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/custom_future_builder.dart';
import 'package:spotify_prj/presentation/song_list_screen/models/song_list_model.dart';

import 'Widgets/song_list_screen_widgets.dart';
import 'controller/song_list_controller.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SongListController controller = Get.put(SongListController());
    AudioController audioController = Get.find();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SongListScreenWidgets().songDetails(controller),
            CustomFutureBuilder(
              future: controller.songList,
              onSuccess: (p0, p1) {
                return ListView.builder(
                  itemCount: p1!.length,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final data = p1![index];
                    return ListTile(
                      leading: SizedBox(
                        width: 45,
                        child: Image.network(
                          data.track.album.images![0].url!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error);
                          },
                        ),
                      ),
                      title: Text(
                        data.track.name!,
                        style: TextStyle(color: Colors.grey),
                      ),
                      subtitle: Text(
                        data.track.artists
                            .take(2)
                            .map((names) => names.name)
                            .join(','),
                        style: TextStyle(color: Colors.grey,fontSize: 12),
                      ),
                      onTap: () {
                        // Clear the existing queue if needed
                        audioController.queueSongs.clear();
                        // Add the selected song and all subsequent songs to the queue
                        for (int i = index; i < p1.length; i++) {
                          final currentItem = p1[i];
                          audioController.addToQueue(
                            currentItem.track!.name!,
                            currentItem.track!.album!.artists![0].name!,
                            currentItem.track!.album!.images![0].url!,
                          );
                        }
                        // Start playback with the first song in the updated queue
                        audioController.getVideoIdFromSearch(0);
                      },
                    );
                  },
                );
              },
              waiting: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(
              height: 40.h,
            )
          ],
        ),
      ),
      bottomSheet: BottomNavWidgets().musicPlayer(audioController),
    );
  }
}
