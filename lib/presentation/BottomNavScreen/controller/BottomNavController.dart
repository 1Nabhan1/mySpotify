import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../LibraryScreen/LibraryScreen.dart';
import '../../SearchScreen/SearchScreen.dart';
import '../../home_screen/HomePage.dart';

class Bottomnavcontroller extends GetxController {
  // Index of the currently selected tab
  var selectedIndex = 0.obs;

  // List of pages
  final List<Widget> pages = [
    Homepage(),
    Searchscreen(),
    Libraryscreen(),
  ];

  // Update the selected index
  void changePage(int index) {
    selectedIndex.value = index;
  }
}
