import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:himotoku/Views/RouteBuilder.dart';
import 'package:himotoku/Sources/SourceHelper.dart';
import 'package:himotoku/Views/source_explore.dart';

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
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: SourcesMap.length,
                itemBuilder: (context, index) {
                  final key = SourcesMap.keys.elementAt(index);
                  final value = SourcesMap.values.elementAt(index);
                  return Column(
                    children: [
                      ListTile(
                          contentPadding: const EdgeInsets.all(5),
                          onTap: () {
                            Navigator.of(context).push(createRoute(
                              SourceExplore(
                                value,
                              ),
                            ));
                          },
                          title: Text(key),
                          leading: CachedNetworkImage(
                            imageUrl: value.iconUrl,
                            fit: BoxFit.fitWidth,
                            width: 32,
                            height: 32,
                            memCacheWidth: 64,
                          )),
                      const Divider(),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
