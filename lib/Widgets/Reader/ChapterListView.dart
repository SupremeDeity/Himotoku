// ignore_for_file: prefer_const_constructors, non_constant_identifier_names,

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Views/RouteBuilder.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/models/Setting.dart';
import 'package:himotoku/Sources/SourceHelper.dart';

class ChapterListView extends StatefulWidget {
  const ChapterListView(this.manga, this.chapterIndex, {Key? key})
      : super(key: key);

  final int chapterIndex;
  final Manga manga;

  @override
  State<ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<ChapterListView> {
  bool fullscreen = false;
  bool isFocused = false;
  bool isRead = false;
  List<String> pageLinks = [];
  Stream<List<Widget>>? pageGenStream;

  final ScrollController _scrollController = ScrollController();

  // Loads images sequentially (one-by-one)
  Stream<List<Widget>> generatePages() async* {
    int len = pageLinks.length;
    List<Widget> loaded = List.filled(
        len,
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 200.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ));

    for (int x = 0; x < len; x++) {
      var response = await http.get(Uri.parse(pageLinks[x]));
      var image = Image.memory(
        fit: BoxFit.cover,
        response.bodyBytes,
      );
      setState(() {
        loaded[x] = image;
      });
      yield loaded;
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    updateSettings();
    // * Check if page is already read.
    // TODO: find a better solution to this.
    setState(() {
      isRead = widget.manga.chapters[widget.chapterIndex].isRead;
    });

    // Get all page links chapter.
    getPageLinks();

    _scrollController.addListener(() {
      if (!isRead) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 800) {
          setChapterAsRead();
        }
      }
    });
    pageGenStream = generatePages();
    super.initState();
  }

  updateSettings() async {
    var settings = await isarDB.settings.get(0);
    setState(() {
      fullscreen = settings!.fullscreen;
    });
    if (fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  getPageLinks() async {
    try {
      List<String>? newItems = await SourcesMap[widget.manga.source]!
          .getChapterPageList(widget.manga.chapters[widget.chapterIndex].link!);
      if (newItems!.isEmpty) {
        Navigator.of(context).pop(APP_ERROR.CHAPTER_NO_PAGES);
      }
      setState(() {
        pageLinks = newItems;
      });
    } catch (e) {
      Logger logger = Logger();
      logger.e(e);
      Navigator.of(context).pop("An error occured while fetching pages.");
    }
  }

  setChapterAsRead() async {
    setState(() {
      isRead = true;
    });
    await isarDB.writeTxn(() {
      widget.manga.chapters[widget.chapterIndex].isRead = true;
      return isarDB.mangas.put(widget.manga);
    });
  }

  setCurrentScroll(double value) {
    _scrollController.jumpTo(value);
  }

  Container HeaderView(BuildContext context) {
    return Container(
      // Note: SafeArea not used to avoid giving a empty invisible gap at the top
      height: MediaQuery.of(context).viewPadding.top + 60,
      width: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            Text(
              widget.manga.chapters[widget.chapterIndex].name ?? "Unknown",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.open_in_browser,
                  ),
                  onPressed: () {
                    launchUrl(
                        Uri.parse(
                            widget.manga.chapters[widget.chapterIndex].link!),
                        mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container FooterView(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton.icon(
            label: Text("Prev"),
            onPressed: widget.chapterIndex < widget.manga.chapters.length - 1
                ? () {
                    Navigator.of(context).pushReplacement(createRoute(
                        ChapterListView(
                            widget.manga, widget.chapterIndex + 1)));
                  }
                : null,
            icon: Icon(
              size: 30,
              Icons.skip_previous_rounded,
            )),
        ElevatedButton.icon(
            label: Text("Next", style: TextStyle()),
            onPressed: widget.chapterIndex > 0
                ? () {
                    Navigator.of(context).pushReplacement(createRoute(
                        ChapterListView(
                            widget.manga, widget.chapterIndex - 1)));
                  }
                : null,
            icon: Icon(
              size: 30,
              Icons.skip_next_rounded,
            )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: pageLinks.isNotEmpty && pageGenStream != null
          ? Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (fullscreen) {
                      if (!isFocused) {
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge);
                      } else {
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.immersive);
                      }
                    }
                    setState(() {
                      isFocused = !isFocused;
                    });
                  },
                  child: StreamBuilder<List<Widget>>(
                    stream: pageGenStream,
                    initialData: List.generate(
                      pageLinks.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 200.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasData && !snapshot.hasError) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              controller:
                                  _scrollController, // only add controller if all pages are loaded
                              itemBuilder: (context, index) =>
                                  snapshot.data![index],
                            );
                          }
                          break;
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
                isFocused
                    ? Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: SafeArea(
                          bottom: true,
                          left: false,
                          right: false,
                          top: false,
                          child: FooterView(context),
                        ),
                      )
                    : Container(),
                isFocused ? HeaderView(context) : Container()
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
