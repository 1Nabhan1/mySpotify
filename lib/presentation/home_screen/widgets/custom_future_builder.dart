import 'package:flutter/cupertino.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  const CustomFutureBuilder({
    super.key,
    required this.future,
    required this.onSuccess,
    required this.waiting,
  });
  final Future<T> future;
  final Widget Function(BuildContext, T) onSuccess;
  final Widget waiting;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return onSuccess(context, snapshot.data!);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return waiting;
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
