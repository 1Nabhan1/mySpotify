class ApiList {
  static String baseUrl = 'https://api.spotify.com/v1';
  static String accBaseUrl = 'https://accounts.spotify.com';
  static String tokenGen = '${accBaseUrl}/api/token';
  static String user = '${baseUrl}/me';
  static String playList = '${baseUrl}/me/playlists';
  static String liked = '${baseUrl}/me/tracks';
  static String recent = '${baseUrl}/me/player/recently-played';
  static String category = '${baseUrl}/browse/categories';
  static String topTracks = '${baseUrl}/me/top/tracks';
}