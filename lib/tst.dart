// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'yt-dlp Test',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: TestPage(),
//     );
//   }
// }
//
// class TestPage extends StatefulWidget {
//   @override
//   _TestPageState createState() => _TestPageState();
// }
//
// class _TestPageState extends State<TestPage> {
//   static const platform = MethodChannel('com.example.spotify_prj/yt_dlp');
//   String _audioUrl = "No URL yet";
//
//   // Method to invoke native code and get the audio URL
//   Future<void> getAudioUrl(String videoId) async {
//     try {
//       final String audioUrl = await platform.invokeMethod('getAudioUrl', {'videoId': videoId});
//       setState(() {
//         _audioUrl = audioUrl.isEmpty ? "Failed to get URL" : audioUrl;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         _audioUrl = "Error: ${e.message}";
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("yt-dlp Test Page"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () async {
//                 String videoId = "9XaS93WMRQQ"; // Replace this with the YouTube video ID you want to test
//                 await getAudioUrl(videoId);
//               },
//               child: Text('Get Audio URL from YouTube'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Audio URL:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             SelectableText(
//               _audioUrl,
//               style: TextStyle(fontSize: 16, color: Colors.blue),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Make sure the video is publicly available on YouTube!',
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
