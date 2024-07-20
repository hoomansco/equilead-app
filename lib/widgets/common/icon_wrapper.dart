import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class IconWrapper extends StatelessWidget {
  const IconWrapper({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onTap,
      child: Container(
        height: 40,
        width: 40,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            width: 0.5,
            color: Color(0xffDEDEDE),
          ),
        ),
        child: SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
        ),
      ),
    );
  }
}
