import 'package:flutter/cupertino.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  const CustomFutureBuilder({
    super.key,
    required this.future,
    required this.onSuccess,
  });
  final Future<T> future;
  final Widget Function(BuildContext, T) onSuccess;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return onSuccess(context, snapshot.data!);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox.shrink(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Somthing Went Wrong'),
          );
        } else {
          return Center(
            child: SizedBox.shrink(),
          );
        }
      },
    );
  }
}
