import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/data/apiClient/ApiList/Apilist.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../../core/constants/api_methods.dart';

class Searchcontroller extends GetxController {
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String? nowPlayingTitle;
  String? nowPlayingArtist;
  bool isPlaying = false;
  int? currentlyPlayingTrackIndex;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> search({required String query}) async {
    Searchcontroller searchController = Get.find();
    final url = ApiList.search(query: query, type: 'track');
    isLoading = true;
    update();
    try {
      final response = await ApiMethods().get(
        url: url,
        headers: {
          'Authorization': 'Bearer ${Constdetails().token}',
        },
      );
      final data = jsonDecode(response);
      searchController.searchResults = data['tracks']['items'];
      // trackLoadingState = List<bool>.filled(searchResults.length, false);
      searchController.isLoading = false;
      update();
    } catch (e, s) {
      searchController.isLoading = false;
      update();
      print(e);
      print(s);
    }
  }

  // Future<void> searchTracks(String query) async {
  //   if (query.isEmpty) {
  //     searchResults = [];
  //     update();
  //     return;
  //   }
  //
  //   isLoading = true;
  //   update();
  //
  //   final String apiUrl = ApiList.search(query: query, type: 'track');
  //
  //   final response = await http.get(
  //     Uri.parse(apiUrl),
  //     headers: {
  //       'Authorization': 'Bearer ${Constdetails().token}',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     searchResults = data['tracks']['items'];
  //     trackLoadingState = List<bool>.filled(
  //         searchResults.length, false); // Initialize loading state
  //     isLoading = false;
  //     update();
  //   } else {
  //     print('Failed to search tracks: ${response.body}');
  //     isLoading = false;
  //     update();
  //   }
  // }
}
