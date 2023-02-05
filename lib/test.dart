// import 'dart:math';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:http/http.dart' as http;

// class Test extends StatefulWidget {
//   const Test({Key? key}) : super(key: key);

//   @override
//   _TestState createState() => _TestState();
// }

// class _TestState extends State<Test> {
//   Future<Widget> cropImage() async {
//     var request = await http.get(Uri.parse(
//         "https://asurascans.com/wp-content/uploads/2022/10/03-47.jpg"));
//     var imgToCrop =
//         img.findDecoderForData(request.bodyBytes)?.decode(request.bodyBytes);
//     int maxHeight = 6000;

//     List<img.Image> pieceList = <img.Image>[];

//     int y = 0;

//     while (y < imgToCrop!.height) {
//       int h = min(imgToCrop.height - y, maxHeight);
//       pieceList.add(
//         img.copyCrop(imgToCrop, x: 0, y: y, width: imgToCrop.width, height: h),
//       );
//       y += h;
//     }

//     var outputImageList = [];

//     for (img.Image imgs in pieceList) {
//       outputImageList.add(Image.memory(
//         Uint8List.fromList(img.encodeJpg(imgs)),
//         fit: BoxFit.fitWidth,
//       ));
//     }
//     print("completed split");

//     return outputImageList;

//     return Image.memory(img.encodeJpg(imgToCrop!));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: [
//         FutureBuilder<Widget>(
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return snapshot.data!;
//             } else {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//           future: cropImage(),
//         ),
//       ],
//     );
//   }
// }
