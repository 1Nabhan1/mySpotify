import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer(
      {super.key, required this.imgUrl, required this.txt, this.onTap});
  final String imgUrl;
  final String txt;
  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 130,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 120.h,
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Shimmer.fromColors(
                        child: Container(
                          color: Colors.transparent.withOpacity(.1),
                          child: Icon(CupertinoIcons.music_note),
                          height: 120.h,
                          width: double.infinity,
                        ),
                        baseColor: Colors.grey,
                        highlightColor: Colors.white,
                      );
                    }
                  },
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0.h, right: 2, left: 2),
                child: Text(
                  txt,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey),
                  maxLines: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
