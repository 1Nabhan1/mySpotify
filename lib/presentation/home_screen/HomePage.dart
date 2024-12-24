import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/main.dart';
import 'package:spotify_prj/presentation/home_screen/controller/home_controller.dart';

import '../LibraryScreen/Model/library_playlist_model.dart';
import 'models/recent_model.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController());
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            FutureBuilder<recent_play?>(
              future: controller.futureRecent,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;

                  return GridView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: data!.items!.length,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisExtent: 80.h),
                    itemBuilder: (context, index) {
                      final items = data.items![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12),
                        child: Container(
                          decoration:
                              BoxDecoration(color: Colors.grey.shade700),
                          child: Row(
                            children: [
                              Image.network(
                                items.track!.album!.images![0].url!,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                                width: 50,
                              ),
                              Flexible(
                                child: Text(
                                  items.track!.album!.name!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Text('Something Went Wrong'),
                  );
                } else {
                  return Text('No Data');
                }
              },
            ),
          ],
        ));
  }
}
