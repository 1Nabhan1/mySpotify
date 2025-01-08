class ApiList {
  static String baseUrl = 'https://api.spotify.com/v1';
  static String accBaseUrl = 'https://accounts.spotify.com';
  static String tokenGen = '${accBaseUrl}/api/token';
  static String user = '${baseUrl}/me';
  static String playList = '${baseUrl}/me/playlists';
  static String liked = '${baseUrl}/me/tracks?limit=50';
  static String recent = '${baseUrl}/me/player/recently-played';
  static String category = '${baseUrl}/browse/categories';
  static String topTracks = '${baseUrl}/me/top/tracks';
  static String libSngList(String id) {
    return '${ApiList.baseUrl}/playlists/${id}/tracks?limit=60';
  }
  static String search({required String query,required String type}) {
    return 'https://api.spotify.com/v1/search?q=$query&type=$type';
  }
}
