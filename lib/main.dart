import 'package:flutter/material.dart';
import 'package:yomu/Routes/route.gr.dart';

void main() => runApp(YomuMain());

class YomuMain extends StatelessWidget {
  YomuMain({Key? key}) : super(key: key);

  final _router = YomuRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(),
      routerDelegate: _router.delegate(),
      routeInformationParser: _router.defaultRouteParser(),
    );
  }
}
