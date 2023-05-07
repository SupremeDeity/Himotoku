import 'package:flutter/material.dart';
import 'package:himotoku/Data/color_util.dart';

class PaletteColor extends StatelessWidget {
  PaletteColor(this.color, this.onColor, this.text,
      {this.createBorder = false, Key? key})
      : super(key: key);
  final Color color;
  final Color onColor;
  final String text;

  /// Create border around color widget
  final bool createBorder;

  /// The overall dimension of the color container
  final dimension = 84.0;

  /// The padding of the container and font size depends on [basis].
  /// These are calculated using [dimension] / [basis]
  final basis = 7.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(dimension / basis),
          child: SizedBox.square(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: createBorder ? Border.all(color: onColor) : null,
                borderRadius: BorderRadius.circular(dimension / 2),
                color: color,
              ),
              child: Text(
                "${color.toHex()}",
                style: TextStyle(
                    fontSize: dimension / basis,
                    color: onColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            dimension: dimension,
          ),
        ),
        Text(text)
      ],
    );
  }
}
