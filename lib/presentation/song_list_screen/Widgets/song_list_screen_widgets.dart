import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/song_list_screen/controller/song_list_controller.dart';

class SongListScreenWidgets {
  Widget songDetails(SongListController controller){
    return
      Stack(
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
                        style:
                        TextStyle(color: Colors.grey, fontSize: 20),
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
}