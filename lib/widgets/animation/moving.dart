import 'dart:async';

import 'package:flutter/material.dart';

class MovingBheegaran extends StatefulWidget {
  final Widget child;
  final int delayedAnimation;
  final double aniOffsetX;
  final double aniOffsetY;
  final int aniDuration;
  final bool disableButton = true;
  final bool repeat;

  const MovingBheegaran(
      {Key? key,
      required this.delayedAnimation,
      required this.aniOffsetX,
      required this.aniOffsetY,
      required this.aniDuration,
      required this.child,
      this.repeat = false})
      : super(key: key);
  @override
  _MovingBheegaranState createState() => _MovingBheegaranState();
}

class _MovingBheegaranState extends State<MovingBheegaran>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animationOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.aniDuration));

    final curve = CurvedAnimation(curve: Curves.linear, parent: _controller);

    _animationOffset = Tween<Offset>(
            begin: Offset(widget.aniOffsetX, widget.aniOffsetY),
            end: Offset.zero)
        .animate(curve);

    Timer(Duration(milliseconds: widget.delayedAnimation), () {
      if (mounted) {
        _controller.forward();
      }
    });
    _controller.addStatusListener((status) {
      if (widget.repeat) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animationOffset,
      child: widget.child,
    );
  }
}
