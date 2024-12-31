// class AudioController extends GetxController {
//   var currentlyPlayingTrackIndex = RxInt(-1);
//   var trackLoadingState = <RxBool>[].obs;
//   var nowPlayingTitle = ''.obs;
//   var nowPlayingArtist = ''.obs;
//   var isPlaying = false.obs;
//   var imgPly = ''.obs;
//   var dominantColor = Colors.transparent.obs;
//   var textColor = Colors.white.obs;
//   final webViewController = Rx<InAppWebViewController?>(null);
//   RxDouble currentPlayingTime = 0.0.obs;
//   RxDouble totalDuration = 0.0.obs;
//   HeadlessInAppWebView? headlessWebView;
//
//   // List to hold the queue of songs
//   var songQueue = <Map<String, dynamic>>[].obs;
//
//   Future<void> playYouTubeAudio(String videoId, String title, String artist, String img) async {
//     await headlessWebView?.dispose();
//     // Create a HeadlessInAppWebView instance
//     headlessWebView = HeadlessInAppWebView(
//       initialUrlRequest: URLRequest(
//         url: WebUri('https://www.youtube.com/watch?v=$videoId'),
//       ),
//       initialSettings: InAppWebViewSettings(
//         mediaPlaybackRequiresUserGesture: false, // Allow autoplay without user interaction
//         allowContentAccess: false, // Disable content access for extra security
//         allowFileAccess: false, // Disable file access
//       ),
//       onWebViewCreated: (controller) {
//         print("WebView Created");
//
//         // Attach JavaScript handler for playback status
//         controller.addJavaScriptHandler(
//           handlerName: 'audioPlaying',
//           callback: (args) {
//             if (args.isNotEmpty && args[0] is bool) {
//               isPlaying.value = args[0];
//               print("Audio is playing: ${isPlaying.value}");
//             }
//           },
//         );
//
//         // Attach JavaScript handler for current time and duration
//         controller.addJavaScriptHandler(
//           handlerName: 'audioProgress',
//           callback: (args) {
//             if (args.isNotEmpty && args.length == 2) {
//               final currentTime = args[0];
//               final duration = args[1];
//               print("Current Time: $currentTime, Total Duration: $duration");
//               currentPlayingTime.value = currentTime;
//               totalDuration.value = duration;
//             }
//           },
//         );
//       },
//       onLoadStop: (controller, url) async {
//         print("Page loaded: $url");
//
//         // Inject JavaScript to autoplay the video and ensure it is not muted
//         await controller.evaluateJavascript(source: """
//         var video = document.querySelector('video');
//         if (video) {
//           var playPromise = video.play();
//           if (playPromise !== undefined) {
//             playPromise.then(() => {
//               console.log("Video is playing");
//               window.flutter_inappwebview.callHandler('audioPlaying', true);
//
//               // Continuously report the playback progress
//               setInterval(() => {
//                 var currentTime = video.currentTime; // Current playback time
//                 var duration = video.duration; // Total duration
//                 window.flutter_inappwebview.callHandler('audioProgress', currentTime, duration);
//               }, 1000); // Update every second
//             }).catch(error => {
//               console.error("Error while trying to play the video:", error);
//               window.flutter_inappwebview.callHandler('audioPlaying', false);
//             });
//           }
//           video.muted = false; // Ensure audio is enabled
//         } else {
//           window.flutter_inappwebview.callHandler('audioPlaying', false);
//         }
//       """);
//         nowPlayingTitle.value = title;
//         nowPlayingArtist.value = artist;
//         imgPly.value = img;
//       },
//     );
//
//     try {
//       // Start the Headless WebView
//       await headlessWebView?.run();
//       print("Headless WebView running in background");
//     } catch (e) {
//       print("Error starting Headless WebView: $e");
//       isPlaying.value = false; // Reset to false if there's an error
//     }
//   }
//
//   Future<void> togglePlayPause() async {
//     if (headlessWebView != null) {
//       try {
//         await headlessWebView!.webViewController?.evaluateJavascript(source: """
//         var video = document.querySelector('video');
//         if (video) {
//           if (video.paused) {
//             video.play();
//             window.flutter_inappwebview.callHandler('audioPlaying', true);
//             console.log("Playback resumed");
//           } else {
//             video.pause();
//             window.flutter_inappwebview.callHandler('audioPlaying', false);
//             console.log("Playback paused");
//           }
//         }
//       """);
//       } catch (e) {
//         print("Error toggling play/pause: $e");
//       }
//     } else {
//       print("No Headless WebView instance available to control playback.");
//     }
//   }
//
//   // Play the next song in the queue
//   void playNextSong() {
//     if (currentlyPlayingTrackIndex.value < songQueue.length - 1) {
//       currentlyPlayingTrackIndex.value++;
//       final nextSong = songQueue[currentlyPlayingTrackIndex.value];
//       playYouTubeAudio(nextSong['id'], nextSong['name'], nextSong['artist'], nextSong['img']);
//     } else {
//       print("No more songs in the queue.");
//     }
//   }
//
//   // Listen for when the song is completed
//   Future<void> setupSongCompletionListener() async {
//     headlessWebView?.webViewController?.addJavaScriptHandler(
//       handlerName: 'onSongComplete',
//       callback: (args) {
//         print("Song completed");
//         playNextSong(); // Play the next song in the queue
//       },
//     );
//   }
//
//   // Add a song to the queue
//   void addToQueue(String videoId, String title, String artist, String img) {
//     songQueue.add({
//       'id': videoId,
//       'name': title,
//       'artist': artist,
//       'img': img,
//     });
//   }
//
//   Future<void> getVideoIdFromSearch(
//       String query, int index, String imgUrl, String trackArtist) async {
//     final yt = YoutubeExplode();
//     if (trackLoadingState.length <= index) {
//       trackLoadingState.addAll(List.generate(
//           index - trackLoadingState.length + 1, (_) => false.obs));
//     }
//
//     // Mark the track as loading
//     trackLoadingState[index].value = true;
//     currentlyPlayingTrackIndex.value = index;
//
//     // Search YouTube for the query
//     var searchResults = await yt.search.getVideos(query);
//
//     // If there are results, get the first video
//     if (searchResults.isNotEmpty) {
//       var firstVideo = searchResults.first;
//       print("Video ID: ${firstVideo.id}"); // Print video ID
//
//       // Add this song to the queue
//       addToQueue(firstVideo.id, query, trackArtist, imgUrl);
//
//       // If it's the first song, start playing it
//       if (currentlyPlayingTrackIndex.value == 0) {
//         await playYouTubeAudio('${firstVideo.id}', query, trackArtist, imgUrl);
//       }
//     } else {
//       print("No results found.");
//     }
//   }
//
//   String formatTime(double timeInSeconds) {
//     int minutes = timeInSeconds ~/ 60; // Integer division for minutes
//     int seconds = (timeInSeconds % 60).toInt(); // Remainder for seconds
//     return "$minutes:${seconds.toString().padLeft(2, '0')}";
//   }
//
//   @override
//   void onClose() {
//     // audioPlayer.dispose();
//     super.onClose();
//   }
// }
