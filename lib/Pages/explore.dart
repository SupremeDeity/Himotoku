import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yomu/Extensions/ExtensionHelper.dart';
import 'package:yomu/Extensions/asura.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Extensions/manganato.dart';
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
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${ExtensionsMap.length} Sources available',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          ListView(
              shrinkWrap: true,
              children: List.generate(
                ExtensionsMap.length,
                (index) => Column(
                  children: [
                    const Divider(),
                    ListTile(
                        contentPadding: const EdgeInsets.all(5),
                        onTap: () {
                          Get.to(
                              () => SourceExplore(
                                  ExtensionsMap.values.elementAt(index)),
                              transition: Transition.noTransition);
                        },
                        title: Text(ExtensionsMap.keys.elementAt(index)),
                        leading: CachedNetworkImage(
                          imageUrl:
                              ExtensionsMap.values.elementAt(index).iconUrl,
                          width: 32,
                          height: 32,
                        )),
                  ],
                ),
              )),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(1),
    );
  }
}
