import 'dart:async';

import 'package:flutter/material.dart';

class DelayedAnimation extends StatefulWidget {
  final Widget child;
  final int delayedAnimation;
  final double aniOffsetX;
  final double aniOffsetY;
  final int aniDuration;
  final bool disableButton = true;
  final bool repeat;

  const DelayedAnimation({
    Key? key,
    required this.delayedAnimation,
    required this.aniOffsetX,
    required this.aniOffsetY,
    required this.aniDuration,
    required this.child,
    this.repeat = false,
  }) : super(key: key);

  @override
  _DelayedAnimationState createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<DelayedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animationOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.aniDuration),
    );

    final curve = CurvedAnimation(
      curve: Curves.decelerate,
      parent: _controller,
    );

    _animationOffset = Tween<Offset>(
      begin: Offset(widget.aniOffsetX, widget.aniOffsetY),
      end: Offset.zero,
    ).animate(curve);

    Timer(
      Duration(milliseconds: widget.delayedAnimation),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _animationOffset,
        child: widget.child,
      ),
      opacity: _controller,
    );
  }
}
