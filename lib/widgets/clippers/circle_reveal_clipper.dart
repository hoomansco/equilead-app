import 'dart:math';

import 'package:flutter/material.dart';

class CircleRevealClipper extends CustomClipper<Path> {
  final double revealPercent;
  final Offset center;

  CircleRevealClipper(this.revealPercent, this.center);

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: sqrt(size.width * size.width + size.height * size.height) *
              revealPercent,
        ),
      );
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.revealPercent != revealPercent;
  }
}
