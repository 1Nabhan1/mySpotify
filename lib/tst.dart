// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'models_data.dart';
//
// class ApiMethod {
//   Future<dynamic> get({required String url}) async {
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       print(response.body);
//       final data = response.body;
//       return data;
//     } else {
//       print('Error occurred status: ${response.statusCode}');
//       print('Error occurred: ${response.body}');
//     }
//   }
// }
//
// class Tst extends StatefulWidget {
//   Tst({super.key});
//
//   @override
//   State<Tst> createState() => _TstState();
// }
//
// class _TstState extends State<Tst> {
//   late Future<ModelsData?> futureData;
//   Future<ModelsData?> fetchTst() async {
//     try {
//       final data = await ApiMethod()
//           .get(url: 'https://tackletips.in/api/product-view?id=300000');
//       return ModelsData.fromJson(jsonDecode(data));
//     } catch (e) {
//       print(e);
//     }
//     return null;
//   }
//
//   // Future<ModelsData?> fetchDatas() async {
//   //   String url = 'https://tackletips.in/api/product-view?id=3';
//   //   final response = await http.get(Uri.parse(url));
//   //   if (response.statusCode == 200) {
//   //     final data = jsonDecode(response.body);
//   //     return ModelsData.fromJson(data);
//   //   } else {
//   //     print(response.statusCode);
//   //     print(response.body);
//   //   }
//   //   return null;
//   // }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     futureData = fetchTst();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<ModelsData?>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final data = snapshot.data;
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(data!.data!.brand!.name!),
//                 Text('Group Details'),
//                 ListView.builder(
//                   scrollDirection: Axis.vertical,
//                   shrinkWrap: true,
//                   physics: BouncingScrollPhysics(),
//                   itemCount: data!.data!.group!.length,
//                   itemBuilder: (context, index) {
//                     final grp = data!.data!.group![index];
//                     return ListTile(
//                       leading: Text('${grp.id!}'),
//                       title: Text(grp!.name!),
//                     );
//                     Column(
//                       children: [
//                         Text(grp.name!),
//                         Text(grp.name!),
//                       ],
//                     );
//                   },
//                 )
//               ],
//             );
//           } else if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             print(snapshot.error);
//             return Center(
//               child: Text('Something Went Wrong'),
//             );
//           } else {
//             return Center(
//               child: Text('No Data'),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
