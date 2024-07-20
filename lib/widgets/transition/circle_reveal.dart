import 'package:flutter/material.dart';

class CircleRevealTransitionPage<T> extends Page<T> {
  final Widget child;

  CircleRevealTransitionPage({
    required this.child,
    required LocalKey key,
  }) : super(key: key);

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      settings: this,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return CircleRevealTransition(
          animation: animation,
          child: child,
        );
      },
    );
  }
}

class CircleRevealTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  CircleRevealTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: _CircleRevealClipper(animation.value),
      child: child,
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Rect> {
  final double fraction;

  _CircleRevealClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * fraction * 1.2;
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  bool shouldReclip(oldClipper) => true;
}
