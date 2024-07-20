import 'package:flutter/material.dart';
import 'package:equilead/widgets/animation/moving.dart';

class SwipeIconRegister extends StatefulWidget {
  final String? title;
  final VoidCallback? onSwipe;
  const SwipeIconRegister({Key? key, this.title, this.onSwipe})
      : super(key: key);

  @override
  _SwipeIconRegisterState createState() => _SwipeIconRegisterState();
}

class _SwipeIconRegisterState extends State<SwipeIconRegister> {
  double _iconPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50.0, // Adjust height as needed
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.title!,
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _iconPosition += details.delta.dx * 1.4;
                _iconPosition = _iconPosition.clamp(
                  0.0,
                  MediaQuery.of(context).size.width * 0.66,
                ); // Restrict movement within container
              });
            },
            onHorizontalDragEnd: (details) {
              if (_iconPosition > MediaQuery.of(context).size.width * 0.4) {
                widget.onSwipe!();
              } else {
                setState(() {
                  _iconPosition = 0.0;
                });
              }
            },
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  left: _iconPosition,
                  top: 0,
                  bottom: 0,
                  child: MovingBheegaran(
                    delayedAnimation: 400,
                    aniOffsetX: 0.12,
                    aniOffsetY: 0,
                    aniDuration: 500,
                    repeat: true,
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(70.0),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 24, // Adjust icon size
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
