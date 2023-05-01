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
          children: [
            ListTile(
              title: Text(
                'Sources [${SourcesMap.length}]',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: SourcesMap.length,
                  itemBuilder: (ctx, index) {
                    final key = SourcesMap.keys.elementAt(index);
                    final value = SourcesMap.values.elementAt(index);
                    return ListTile(
                      onTap: () => Navigator.of(ctx)
                          .push(createRoute(SourceExplore(value))),
                      leading: CachedNetworkImage(
                        imageUrl: value.iconUrl,
                        height: 24,
                        width: 24,
                        memCacheHeight: 70,
                        maxHeightDiskCache: 70,
                      ),
                      trailing: Icon(Icons.arrow_circle_right_outlined),
                      title: Text(
                        key,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    );
                  }),
            )
          ],
        ));
  }
}
