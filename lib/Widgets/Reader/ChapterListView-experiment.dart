// ignore_for_file: 
// import 'dart:convert';
// import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:isar/isar.dart';
// import 'package:logger/logger.dart';
// import 'package:himotoku/Data/Manga.dart';
// import 'package:himotoku/Data/Setting.dart';
// import 'package:himotoku/Sources/SourceHelper.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as imglib;

// class ChapterListView extends StatefulWidget {
//   ChapterListView(this.manga, this.chapterIndex, {Key? key}) : super(key: key);

//   int chapterIndex;
//   Manga manga;

//   @override
//   State<ChapterListView> createState() => _ChapterListViewState();
// }

// class _ChapterListViewState extends State<ChapterListView> {
//   int currentlyLoaded = 0;
//   bool fullscreen = false;
//   bool splitTallImages = false;
//   bool isFocused = false;
//   bool isRead = false;
//   var isarDB = Isar.getInstance(ISAR_INSTANCE_NAME)!;
//   List<String> pageLinks = [];
//   List<dynamic> pages = [];

//   final ScrollController _scrollController = ScrollController();

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }

//   @override
//   void initState() {
//     updateSettings();
//     // Check if page is already read.
//     setState(() {
//       isRead = widget.manga.chapters[widget.chapterIndex].isRead;
//     });

//     // Get all page links chapter.
//     getPages();

//     _scrollController.addListener(() {
//       if (!isRead) {
//         if (_scrollController.offset >=
//             _scrollController.position.maxScrollExtent - 800) {
//           setChapterAsRead();
//         }
//       }
//     });

//     super.initState();
//   }

//   split_load(int index) {
//     print("started");

//     if (!splitTallImages) {
//       if (mounted) {
//         setState(() {
//           pages[currentlyLoaded] = Image(
//             httpHeaders: {"Referer": widget.manga.mangaLink},
//             imageUrl: pageLinks[index],
//             filterQuality: FilterQuality.medium,
//             errorWidget: (context, url, error) {
//               return Text("Error: $error");
//             },
//           );
//           currentlyLoaded++;
//         });
//         if (currentlyLoaded < pageLinks.length) {
//           split_load(currentlyLoaded);
//         }
//       }

//       return;
//     }

//     // Split & Load pages
//     compute(splitImage, pageLinks[index]).then(
//       (value) {
//         if (mounted) {
//           setState(() {
//             pages.addAll(value);
//             currentlyLoaded++;
//           });
//         }
//         // return value;
//       },
//     );
//   }

//   updateSettings() async {
//     var settings = await isarDB.settings.get(0);
//     setState(() {
//       fullscreen = settings!.fullscreen;
//       splitTallImages = settings.splitTallImages;
//     });
//     if (fullscreen) {
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
//     }
//   }

//   getPages() async {
//     try {
//       final newItems = await SourcesMap[widget.manga.sourceSource]!
//           .getChapterPageList(widget.manga.chapters[widget.chapterIndex].link!);
//       setState(() {
//         pageLinks = newItems;
//         // TODO: WOWOW
//       });

//       setState(() {
//         pages.add(List.generate(
//           pageLinks.length,
//           (_) {
//             return CircularProgressIndicator();
//           },
//         ));
//       });

//       split_load(currentlyLoaded);
//     } catch (e) {
//       var logger = Logger();

//       logger.e(e);
//     }
//   }

//   setChapterAsRead() async {
//     setState(() {
//       isRead = true;
//     });
//     await isarDB.writeTxn(() {
//       widget.manga.chapters[widget.chapterIndex].isRead = true;
//       return isarDB.mangas.put(widget.manga);
//     });
//   }

//   setCurrentScroll(double value) {
//     _scrollController.jumpTo(value);
//   }

//   Image ChapterPage(int index) {
//     return Image(
//       httpHeaders: {"Referer": widget.manga.mangaLink},
//       imageUrl: pageLinks[index],
//       filterQuality: FilterQuality.medium,
//       errorWidget: (context, url, error) {
//         return Text("Error: $error");
//       },
//       progressIndicatorBuilder: (context, url, progress) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(
//             vertical: 200,
//           ),
//           child: Center(
//             child: CircularProgressIndicator(
//               value: progress.progress,
//               color: context.theme.colorScheme.secondary,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Container HeaderView(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(15.0),
//       // Note: SafeArea not used to avoid giving a empty invisible gap at the top
//       height: MediaQuery.of(context).viewPadding.top + 60,
//       width: double.infinity,
//       color: context.theme.colorScheme.primary,
//       child: SafeArea(
//         bottom: false,
//         left: false,
//         right: false,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.manga.chapters[widget.chapterIndex].name ?? "Unknown",
//               style: const TextStyle(
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Container FooterView(BuildContext context) {
//     return Container(
//       color: context.theme.colorScheme.primary.withAlpha(220),
//       child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//         ElevatedButton.icon(
//             label: Text("Prev"),
//             onPressed: widget.chapterIndex < widget.manga.chapters.length - 1
//                 ? () {
//                     // Get.off(
//                     //   () => ChapterListView(
//                     //       widget.manga, widget.chapterIndex + 1),
//                     //   transition: Transition.noTransition,
//                     //   preventDuplicates: false,
//                     // );
//                   }
//                 : null,
//             icon: const Icon(
//               size: 30,
//               Icons.skip_previous_rounded,
//             )),
//         ElevatedButton.icon(
//             label: Text("Next"),
//             // color: context.theme.colorScheme
//             //     .onSecondaryContainer,
//             onPressed: widget.chapterIndex > 0
//                 ? () {
//                     // Get.off(
//                     //     () => ChapterListView(
//                     //         widget.manga, widget.chapterIndex - 1),
//                     //     transition: Transition.noTransition,
//                     //     preventDuplicates: false);
//                   }
//                 : null,
//             icon: const Icon(
//               size: 30,
//               Icons.skip_next_rounded,
//             )),
//       ]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: pageLinks.isNotEmpty
//           ? Stack(
//               children: [
//                 GestureDetector(
//                     onTap: () {
//                       if (fullscreen) {
//                         if (!isFocused) {
//                           SystemChrome.setEnabledSystemUIMode(
//                               SystemUiMode.edgeToEdge);
//                         } else {
//                           SystemChrome.setEnabledSystemUIMode(
//                               SystemUiMode.immersive);
//                         }
//                       }
//                       setState(() {
//                         isFocused = !isFocused;
//                       });
//                     },
//                     child: pages.isNotEmpty
//                         ? ListView.builder(
//                             itemBuilder: (context, index) {
//                               print("index: $index");
//                               if (index < pages.length) {
//                                 return pages[index];
//                               } else {
//                                 return Container();
//                               }
//                               // else {
//                               //   return currentlyLoaded < pageLinks.length
//                               //       ? const Center(
//                               //           child: Padding(
//                               //             padding: EdgeInsets.symmetric(
//                               //                 vertical: 300),
//                               //             child: CircularProgressIndicator(),
//                               //           ),
//                               //         )
//                               //       : Container();
//                               // }
//                             },
//                             itemCount: pages.length + 1,
//                           )
//                         : const Center(
//                             child: CircularProgressIndicator(),
//                           )),
//                 isFocused
//                     ? Align(
//                         alignment: AlignmentDirectional.bottomEnd,
//                         child: SafeArea(
//                           bottom: true,
//                           left: false,
//                           right: false,
//                           top: false,
//                           child: FooterView(context),
//                         ),
//                       )
//                     : Container(),
//                 isFocused ? HeaderView(context) : Container(),
//               ],
//             )
//           : Center(
//               child: CircularProgressIndicator(
//               color: context.theme.colorScheme.secondary,
//             )),
//     );
//   }
// }

// Future<List> splitImage(String url) async {
//   print("started split");
//   Uri uri = Uri.parse(url);

//   http.Response response =
//       await http.get(Uri.parse(url), headers: {"Referer": uri.authority});
//   Uint8List imagebytes = response.bodyBytes;

//   List<Image> outputImageList = <Image>[];
//   imglib.Image? image = imglib.decodeJpg(imagebytes);

//   // The max height before a image gets split
//   int maxHeight = 6000;

//   List<imglib.Image> pieceList = <imglib.Image>[];

//   int y = 0;

//   while (y < image!.height) {
//     int h = min(image.height - y, maxHeight);
//     pieceList.add(
//       imglib.copyCrop(image, 0, y, image.width, h),
//     );
//     y += h;
//   }

//   for (imglib.Image img in pieceList) {
//     outputImageList.add(Image.memory(
//       Uint8List.fromList(imglib.encodeJpg(img)),
//       fit: BoxFit.fitWidth,
//     ));
//   }
//   print("completed split");

//   return outputImageList;
// }
