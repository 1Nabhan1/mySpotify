import 'package:get/get.dart';
import 'package:spotify_prj/data/apiClient/ApiServices/ApiServices.dart';

class Librarycontroller extends GetxController{

  late Future<List<dynamic>> futurePlaylists;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    futurePlaylists = Apiservices().fetchPlaylists();

  }
}