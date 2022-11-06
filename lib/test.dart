import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  toBitmap() {}

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Image.network(
          "https://asura.gg/wp-content/uploads/2022/10/01-46.jpg",
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        )
      ],
    );
  }
}
