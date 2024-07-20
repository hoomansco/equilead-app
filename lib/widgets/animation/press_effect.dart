import 'package:flutter/material.dart';

class PressEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const PressEffect({super.key, required this.child, required this.onPressed});

  @override
  State<PressEffect> createState() => _PressEffectState();
}

class _PressEffectState extends State<PressEffect> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTapDown: (_) => {setState(() => _isPressed = true)},
      onTapUp: (_) => setState(
          () => _isPressed = false), // not called, TextButton swallows this.
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        setState(() => _isPressed = true);
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() => _isPressed = false);
        });
        widget.onPressed();
      },
      behavior: HitTestBehavior.translucent,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        opacity: _isPressed ? 0.8 : 1,
        child: widget.child,
      ),
    );
  }
}
