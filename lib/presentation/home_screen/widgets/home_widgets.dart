import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/main.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/custom_container.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/custom_future_builder.dart';
import 'package:spotify_prj/routes/PageList.dart';

import '../../../data/apiClient/ApiList/Apilist.dart';
import '../../Player_screen/controllers/audio_controller.dart';
import '../controller/home_controller.dart';
import '../models/album_model.dart';
import '../models/category_model.dart' as cat;
import '../models/recent_model.dart';
import '../models/top_tracks_model.dart';

class HomeWidgets {
  Widget customDrawer({required HomeController controller}) {
    return Drawer(
      backgroundColor: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900,
                        borderRadius: BorderRadius.circular(20.r)),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Obx(
                        () => Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Obx(
                                  () => Image.network(
                                    controller.userData['images'] != null &&
                                            controller.userData['images']
                                                    .toString() !=
                                                '[]'
                                        ? controller.userData['images'][0]
                                            ['url']
                                        : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTc9u0ivNIe4qiLFg2OwPvX-YFTCo8K-AoLhg&s',
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(CupertinoIcons.person);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Text(
                              controller.userData['display_name'] ?? '',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                              controller.userData['email'] ?? '',
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.grey,
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                box.erase();
                Get.offAllNamed(PageList.authScreen);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget customAppbar({required HomeController controller}) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Padding(
          padding: EdgeInsets.only(top: 30.0.h, left: 10, bottom: 10.h),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    controller.scaffoldKey.currentState?.openDrawer();
                    // print(controller.userData['images'][0]['url']);
                  },
                  child: CircleAvatar(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Obx(
                        () => Image.network(
                          controller.userData['images'] != null &&
                                  controller.userData['images'].toString() !=
                                      '[]'
                              ? controller.userData['images'][0]['url']
                              : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTc9u0ivNIe4qiLFg2OwPvX-YFTCo8K-AoLhg&s',
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(CupertinoIcons.person);
                          },
                        ),
                      ),
                    ),
                  )),
            ],
          )),
    );
  }

  Widget customText({required String txt}) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
      ),
      child: Text(
        txt,
        style: TextStyle(
            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 22),
      ),
    );
  }

  Widget categorised({required HomeController controller}) {
    return SizedBox(
      height: 190.h,
      child: CustomFutureBuilder<cat.CategoryModel?>(
        waiting: SizedBox(),
        future: controller.futureCategories,
        onSuccess: (p0, p1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisExtent: 60.h),
            itemBuilder: (context, index) {
              final items = p1!.categories!.items![index];
              return GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                              items.icons![0].url!,
                            ),
                            opacity: .5,
                            fit: BoxFit.cover)),
                    child: Center(
                      child: Text(
                        items.name!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget recentSection({required HomeController controller}) {
    AudioController audioController = Get.find();
    return CustomFutureBuilder<recent_play?>(
      waiting: SizedBox(),
      future: controller.futureRecent,
      onSuccess: (p0, p1) {
        return SizedBox(
          height: 230.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              HomeWidgets().customText(txt: 'Recently Played'),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: p1!.items!.length,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final items = p1.items![index];

                    return GestureDetector(
                      onTap: () {
                        // Clear the existing queue if needed
                        audioController.queueSongs.clear();
                        // Add the selected song and all subsequent songs to the queue
                        for (int i = index; i < p1.items!.length; i++) {
                          final currentItem = p1.items![i];
                          audioController.addToQueue(
                            currentItem.track!.name!,
                            currentItem.track!.album!.artists![0].name!,
                            currentItem.track!.album!.images![0].url!,
                          );
                        }
                        // Start playback with the first song in the updated queue
                        audioController.getVideoIdFromSearch(0);
                      },
                      child: CustomContainer(
                          imgUrl: items.track!.album!.images![0].url!,
                          txt: items.track!.name!),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget topArtists({required HomeController controller}) {
    return CustomFutureBuilder(
      waiting: SizedBox(),
      future: controller.futureArtists,
      onSuccess: (p0, p1) {
        return SizedBox(
          height: 230.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeWidgets().customText(txt: 'Artists'),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: p1!.items!.length,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final items = p1.items![index];
                    return CustomContainer(
                      onTap: () {
                        Get.toNamed(PageList.songListScreen, arguments: {
                          'img': '${items.images![0].url}',
                          'name': '${items.name}',
                          'uri':
                              'https://api.spotify.com/v1/artists/${items.id}/top-tracks',
                          'isArtist': true
                        });
                      },
                      imgUrl: items.images![0].url!,
                      txt: items.name!,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget topTrack({required HomeController controller}) {
    AudioController audioController = Get.find();
    return CustomFutureBuilder<TopTracks?>(
      waiting: SizedBox(),
      future: controller.futureTopTracks,
      onSuccess: (p0, p1) {
        return SizedBox(
          height: 230.h,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            HomeWidgets().customText(txt: 'Top Tracks'),
            SizedBox(
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: p1!.items!.length,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final items = p1.items![index];
                  return GestureDetector(
                    onTap: () {
                      // audioController.getVideoIdFromSearch(
                      //     items.name!,
                      //     index,
                      //     items.album!.images![0]!.url!,
                      //     items.album!.artists![0].name!);
                    },
                    child: CustomContainer(
                        imgUrl: items.album!.images![0].url!, txt: items.name!),
                  );
                },
              ),
            )
          ]),
        );
      },
    );
  }

  Widget newRelease({required HomeController controller}) {
    return CustomFutureBuilder(
      waiting: SizedBox(),
      future: controller.futureNewRelease,
      onSuccess: (p0, p1) {
        return SizedBox(
          height: 230.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeWidgets().customText(txt: 'New Released Albums'),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: p1!.albums!.items!.length,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final items = p1.albums!.items![index];
                    return CustomContainer(
                      imgUrl: items.images![0].url!,
                      txt: items.name!,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget albums({required HomeController controller}) {
  //   return CustomFutureBuilder<AlbumList?>(
  //     future: controller.futureAlbumList,
  //     onSuccess: (p0, p1) {
  //       return SizedBox(
  //         height: 230.h,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             HomeWidgets().customText(txt: 'Albums'),
  //             SizedBox(
  //               height: 200.h,
  //               child: ListView.builder(
  //                 scrollDirection: Axis.horizontal,
  //                 itemCount: p1!.albums!.length,
  //                 physics: BouncingScrollPhysics(),
  //                 shrinkWrap: true,
  //                 itemBuilder: (context, index) {
  //                   final items = p1.albums![index];
  //                   return CustomContainer(
  //                     imgUrl: items.images![0].url!,
  //                     txt: items.name!,
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
