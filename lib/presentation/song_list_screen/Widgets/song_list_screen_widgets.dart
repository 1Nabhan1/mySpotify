import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/song_list_screen/controller/song_list_controller.dart';

import '../../Player_screen/controllers/audio_controller.dart';
import '../../home_screen/widgets/custom_future_builder.dart';

class SongListScreenWidgets {
  Widget songDetails(SongListController controller) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.grey.shade600, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    height: 200,
                    child: Image.network(
                      controller.arguments['img'],
                      height: 200.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.arguments['name'],
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: Get.back,
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            )),
      ],
    );
  }

  Widget libLik(
      {required SongListController controller,
      required AudioController audioController}) {
    return CustomFutureBuilder(
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
                data.track.artists.take(2).map((names) => names.name).join(','),
                style: TextStyle(color: Colors.grey, fontSize: 12),
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
    );
  }

  Widget artistSongList(
      {required SongListController controller,
      required AudioController audioController}) {
    return CustomFutureBuilder(
      future: controller.artSongList,
      onSuccess: (p0, p1) {
        return ListView.builder(
          itemCount: p1!.tracks!.length,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final data = p1!.tracks![index];
            return ListTile(
              leading: SizedBox(
                width: 45,
                child: Image.network(
                  data.album!.images![0].url!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
              ),
              title: Text(
                data.name!,
                style: TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                data.artists!.take(2).map((names) => names.name).join(','),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                // Clear the existing queue if needed
                audioController.queueSongs.clear();
                // Add the selected song and all subsequent songs to the queue
                for (int i = index; i < p1.tracks!.length; i++) {
                  final currentItem = p1.tracks![i];
                  audioController.addToQueue(
                    currentItem!.name!,
                    currentItem.album!.artists![0].name!,
                    currentItem.album!.images![0].url!,
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
    );
  }
}
