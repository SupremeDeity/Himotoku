import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yomu/Sources/SourceHelper.dart';
import 'package:yomu/Pages/source_explore.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 12.0),
            child: Text(
              '${SourcesMap.length} source(s)',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          ListView(
              shrinkWrap: true,
              children: List.generate(
                SourcesMap.length,
                (index) => Column(
                  children: [
                    ListTile(
                        contentPadding: const EdgeInsets.all(5),
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 0),
                              pageBuilder: (_, __, ___) => SourceExplore(
                                SourcesMap.values.elementAt(index),
                              ),
                            ),
                          );
                        },
                        title: Text(SourcesMap.keys.elementAt(index)),
                        leading: CachedNetworkImage(
                          imageUrl: SourcesMap.values.elementAt(index).iconUrl,
                          fit: BoxFit.fitWidth,
                          height: 32,
                          width: 32,
                        )),
                    const Divider(),
                  ],
                ),
              )),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(1),
    );
  }
}
