import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yomu/Extensions/asura.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Extensions/manganato.dart';
import 'package:yomu/Routes/route.gr.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  // Map<String, dynamic> manifest = {};

  Map<String, Extension> sources = {
    "Asura Scans": Asura(),
    "Manganato": Manganato(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${sources.length} Sources available',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          ListView(
              shrinkWrap: true,
              children: List.generate(
                sources.length,
                (index) => Column(
                  children: [
                    const Divider(),
                    ListTile(
                        contentPadding: const EdgeInsets.all(5),
                        onTap: () => {
                              AutoRouter.of(context).push(SourceExplore(
                                  extension: sources.values.elementAt(index))),
                            },
                        title: Text(sources.keys.elementAt(index)),
                        leading: CachedNetworkImage(
                          imageUrl: sources.values.elementAt(index).iconUrl,
                          width: 32,
                          height: 32,
                        )),
                  ],
                ),
              )),
        ],
      ),
      bottomNavigationBar:
          const BottomNavBar(1), // #FIXME: Add something to make this dynamic
    );
  }
}
