import 'package:flutter/material.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

enum ButtonType {
  primary,
  secondary,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: type == ButtonType.secondary ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.black,
            width: 0.6,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: type == ButtonType.secondary ? Colors.black : Colors.white,
            height: 1.1,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
