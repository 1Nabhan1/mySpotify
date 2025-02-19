import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/presentation/BottomNavScreen/controller/BottomNavController.dart';
import 'package:spotify_prj/presentation/BottomNavScreen/widgets/BottomNav_widgets.dart';
import 'package:spotify_prj/presentation/LibraryScreen/LibraryScreen.dart';
import 'package:spotify_prj/presentation/home_screen/HomePage.dart';

import '../Player_screen/controllers/audio_controller.dart';
import '../SearchScreen/SearchScreen.dart';

class Bottomnavscreen extends StatelessWidget {
  Bottomnavscreen({super.key});
  @override
  Widget build(BuildContext context) {
    Bottomnavcontroller bottomnavcontroller = Get.put(Bottomnavcontroller());
    AudioController audioController = Get.find();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() =>
          bottomnavcontroller.pages[bottomnavcontroller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
            unselectedItemColor: Colors.grey.shade700,
            selectedItemColor: Colors.white70,
            backgroundColor: Colors.black,
            currentIndex: bottomnavcontroller.selectedIndex.value,
            onTap: (index) => bottomnavcontroller.changePage(index),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: GestureDetector(
                    onTap: () {
                      if (bottomnavcontroller.selectedIndex.value == 1) {
                        audioController.searchNode.requestFocus();
                      }
                    },
                    child: Icon(CupertinoIcons.search)),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.my_library_music_outlined), label: 'Library')
            ]),
      ),
      bottomSheet: BottomSheet(
        enableDrag: false,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        onClosing: () {},
        builder: (context) {
          return BottomNavWidgets().musicPlayer(audioController);
        },
      ),
    );
  }
}
