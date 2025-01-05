import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Controller/LibraryController.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Model/library_playlist_model.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/custom_future_builder.dart';
import 'package:spotify_prj/routes/PageList.dart';

import '../song_list_screen/song_list_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LibraryController librarycontroller = Get.put(LibraryController());
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Your Library',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey.shade800,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 60,
                    child: Image.network(
                      'https://image-cdn-ak.spotifycdn.com/image/ab67706c0000da849d25907759522a25b86a3033',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    ),
                  ),
                  title: Text(
                    'Liked Songs',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Apiservices().refreshAccessToken();
                    Get.toNamed(PageList.songListScreen, arguments: {
                      'id': '${0}',
                      'img':
                          'https://image-cdn-ak.spotifycdn.com/image/ab67706c0000da849d25907759522a25b86a3033',
                      'name': 'Liked Songs',
                      'isLiked': true
                    });
                    print(Constdetails().token);
                  },
                ),
              ),
              CustomFutureBuilder(
                future: librarycontroller.futurePlaylists,
                onSuccess: (p0, p1) {
                  return ListView.builder(
                    itemCount: p1.length,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final data = p1[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: SizedBox(
                            width: 60,
                            child: Image.network(
                              data.images![0].url!,
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
                          onTap: () {
                            // Apiservices().refreshAccessToken();
                            Get.toNamed(PageList.songListScreen, arguments: {
                              'id': '${data.id}',
                              'img': '${data.images![0].url}',
                              'name': '${data.name}',
                              'isLiked': false
                            });
                            print(Constdetails().token);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 40.h,
              )
            ],
          ),
        ));
  }
}
