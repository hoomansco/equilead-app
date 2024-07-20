import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class SpaceNav extends StatelessWidget {
  const SpaceNav({
    super.key,
    this.title,
    this.iconPath,
    required this.onTap,
    required this.flex,
  });

  final String? title;
  final String? iconPath;
  final VoidCallback onTap;
  final int flex;

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Expanded(
      flex: flex,
      child: PressEffect(
        onPressed: onTap,
        child: Container(
          height: 64,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: 0.5,
              color: Colors.black,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title!,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              Spacer(),
              SvgPicture.asset(iconPath!)
            ],
          ),
        ),
      ),
    );
  }
}
