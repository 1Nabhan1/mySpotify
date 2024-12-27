import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/core/controllers/audio_controller.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';
import 'package:spotify_prj/main.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/custom_container.dart';
import 'package:spotify_prj/presentation/home_screen/widgets/custom_future_builder.dart';

import '../controller/home_controller.dart';
import '../models/album_model.dart';
import '../models/category_model.dart' as cat;
import '../models/recent_model.dart';
import '../models/top_tracks_model.dart';

class HomeWidgets {
  Widget customAppbar() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Padding(
        padding: EdgeInsets.only(top: 30.0.h, left: 10),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(
                'L',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(items.icons![0].url ??
                              'https://i.scdn.co/image/ab6761610000e5eb2ac87a070797b92eb8967767'),
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
                        audioController.playTrack(
                            items.track!.album!.name!, index);
                      },
                      child: CustomContainer(
                          imgUrl: items.track!.album!.images![0].url!,
                          txt: items.track!.album!.name!),
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
    return CustomFutureBuilder<TopTracks?>(
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
                  return CustomContainer(
                      imgUrl: items.album!.images![0].url!,
                      txt: items.album!.name!);
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
      future: controller.futureNewRelease,
      onSuccess: (p0, p1) {
        return SizedBox(
          height: 230.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeWidgets().customText(txt: 'New Releases'),
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

  Widget albums({required HomeController controller}) {
    return CustomFutureBuilder<AlbumList?>(
      future: controller.futureAlbumList,
      onSuccess: (p0, p1) {
        return SizedBox(
          height: 230.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeWidgets().customText(txt: 'Albums'),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: p1!.albums!.length,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final items = p1.albums![index];
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
}
