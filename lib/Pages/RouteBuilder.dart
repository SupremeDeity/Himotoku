import 'package:flutter/cupertino.dart';

createRoute(Widget route) {
  return PageRouteBuilder(
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => route,
  );
}
