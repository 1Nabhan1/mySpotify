import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotify_prj/core/constants/ConstDetails.dart';
import 'package:spotify_prj/presentation/LibraryScreen/Controller/LibraryController.dart';

class Libraryscreen extends StatelessWidget {
  const Libraryscreen({super.key});

  @override
  Widget build(BuildContext context) {
    Librarycontroller librarycontroller = Get.put(Librarycontroller());
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<dynamic>>(
        future: librarycontroller.futurePlaylists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final playlists = snapshot.data!;
            return GridView.builder(
              itemCount: playlists.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisExtent: 200),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final name = playlist['name'];
                final description = playlist['description'] ?? '';
                final images = playlist['images'] as List<dynamic>;
                final imageUrl = images.isNotEmpty
                    ? images[0]['url']
                    : 'https://www.google.com/imgres?q=song%20app%20icons&imgurl=https%3A%2F%2Fcdn-icons-png.flaticon.com%2F512%2F8014%2F8014930.png&imgrefurl=https%3A%2F%2Fwww.flaticon.com%2Ffree-icon%2Fsong_8014930&docid=jP0G5GkfhFlmXM&tbnid=gGwqZ-r0ne7cEM&vet=12ahUKEwiti4SNgraKAxVn-DgGHfWpJ0sQM3oFCIUBEAA..i&w=512&h=512&hcb=2&ved=2ahUKEwiti4SNgraKAxVn-DgGHfWpJ0sQM3oFCIUBEAA';

                return GestureDetector(onTap: () {
                  print(Constdetails().Token);
                },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 100,
                                child: Image.network(
                                  imageUrl,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error_outline);
                                  },
                                )),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              description,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text('No data available.'));
        },
      ),
    );
  }
}
