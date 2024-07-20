import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavItem extends StatelessWidget {
  final bool isSelected;
  final String iconPath;
  final String title;
  final VoidCallback onTap;

  const BottomNavItem({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.linearToEaseOut,
        alignment: Alignment.center,
        width: isSelected ? 150 : 56,
        height: 56,
        padding: isSelected
            ? EdgeInsets.symmetric(horizontal: 24, vertical: 12)
            : EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(55),
          color: isSelected ? Colors.black : Color(0xffEBEBEB),
          // border: isSelected
          //     ? null
          //     : Border.all(
          //         color: AppColors.secondaryGray1,
          //         width: 1,
          //       ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Color(0xffA3B0D7).withOpacity(0.1),
          //     spreadRadius: 0,
          //     blurRadius: 5,
          //     offset: Offset(0, 2), // changes position of shadow
          //   ),
          //   BoxShadow(
          //     color: Color(0xffA3B0D7).withOpacity(0.09),
          //     spreadRadius: 0,
          //     blurRadius: 9,
          //     offset: Offset(0, 9), // changes position of shadow
          //   ),
          // ],
        ),
        child: !isSelected
            ? SvgPicture.asset(iconPath, width: 20, height: 20)
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(flex: 1),
                  SvgPicture.asset(
                    iconPath,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 34,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Spacer(flex: 1),
                ],
              ),
      ),
    );
  }
}
