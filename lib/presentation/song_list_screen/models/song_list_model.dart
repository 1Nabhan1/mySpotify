class PlaylistTrackResponse {
  final String href;
  final List<Item> items;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;

  PlaylistTrackResponse({
    required this.href,
    required this.items,
    required this.limit,
    this.next,
    required this.offset,
    this.previous,
    required this.total,
  });

  factory PlaylistTrackResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistTrackResponse(
      href: json['href'],
      items:
          (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      total: json['total'],
    );
  }
}

class Item {
  final String addedAt;
  // final AddedBy addedBy;
  final bool isLocal;
  final Track track;
  // final VideoThumbnail videoThumbnail;

  Item({
    required this.addedAt,
    // required this.addedBy,
    required this.isLocal,
    required this.track,
    // required this.videoThumbnail,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      addedAt: json['added_at'],
      // addedBy: AddedBy.fromJson(json['added_by']),
      isLocal: json['is_local']?? false,
      track: Track.fromJson(json['track']),
      // videoThumbnail: VideoThumbnail.fromJson(json['video_thumbnail']),
    );
  }
}



class ExternalUrls {
  final String spotify;

  ExternalUrls({required this.spotify});

  factory ExternalUrls.fromJson(Map<String, dynamic> json) {
    return ExternalUrls(
      spotify: json['spotify'],
    );
  }
}

class Track {
  final String id;
  final String name;
  final String uri;
  final int durationMs;
  final String externalUrl;
  final Album album;
  final List<Artist> artists;

  Track({
    required this.id,
    required this.name,
    required this.uri,
    required this.durationMs,
    required this.externalUrl,
    required this.album,
    required this.artists,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      uri: json['uri'],
      durationMs: json['duration_ms'],
      externalUrl: json['external_urls']['spotify'],
      album: Album.fromJson(json['album']),
      artists: (json['artists'] as List)
          .map((artist) => Artist.fromJson(artist))
          .toList(),
    );
  }
}

class Album {
  final String id;
  final String name;
  final String releaseDate;
  final Uri uri;
  final List<Artist> artists;
  final List<Images> images;

  Album({
    required this.id,
    required this.name,
    required this.releaseDate,
    required this.uri,
    required this.artists,
    required this.images,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        id: json['id'],
        name: json['name'],
        releaseDate: json['release_date'],
        uri: Uri.parse(json['uri']),
        artists: (json['artists'] as List)
            .map((artist) => Artist.fromJson(artist))
            .toList(),
        images: (json['images'] as List)
            .map((img) => Images.fromJson(img))
            .toList());
  }
}

class Artist {
  final String id;
  final String name;
  final Uri uri;
  final ExternalUrls externalUrls;
  final String href;

  Artist({
    required this.id,
    required this.name,
    required this.uri,
    required this.externalUrls,
    required this.href,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      uri: Uri.parse(json['uri']),
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      href: json['href'],
    );
  }
}

// class VideoThumbnail {
//   final String? url;
//
//   VideoThumbnail({this.url});
//
//   factory VideoThumbnail.fromJson(Map<String, dynamic> json) {
//     return VideoThumbnail(
//       url: json['url'],
//     );
//   }
// }

class Images {
  final int height;
  final int width;
  final String url;

  Images({this.height = 0, this.width = 0, this.url = ''});

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
        width: json['width'], height: json['height'], url: json['url']);
  }
}
