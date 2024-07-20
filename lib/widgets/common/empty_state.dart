import 'package:flutter/material.dart';
import 'package:equilead/theme/colors.dart';

class EmptyState extends StatelessWidget {
  final bool isDark;
  final String text;
  const EmptyState({
    super.key,
    this.isDark = false,
    this.text = "Nothing here yet",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64,
          width: 64,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Color(0xff2e2e2e) : AppColors.secondaryGray1,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            "assets/images/animated/eyes.png",
            height: 72,
          ),
        ),
        SizedBox(height: 16),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
