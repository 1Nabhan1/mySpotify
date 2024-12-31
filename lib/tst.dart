// import 'package:flutter/material.dart';
//
// class Tst extends StatelessWidget {
//   const Tst({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: Text("Draggable Bottom Sheet")),
//       body: Column(
//         children: [
//           Text(
//             'sdjkvnsdvsdomvdpso,vd',
//             style: TextStyle(fontSize: 22),
//           )
//         ],
//       ),
//       bottomSheet: DraggableScrollableSheet(
//         controller: DraggableScrollableController(),
//         expand: false,
//         initialChildSize: 0.1, // Initial size of the bottom sheet
//         minChildSize:
//             0.1, // Minimum size that the bottom sheet can be dragged to
//         // maxChildSize:
//         //     0.6, // Maximum size that the bottom sheet can be dragged to
//         builder: (context, scrollController) {
//           return Container(
//             color: Colors.blue,
//             child: ListView.builder(
//               controller: scrollController,
//               itemCount: 20,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text("Item #$index"),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
