import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class CheckinChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  const CheckinChip({
    super.key,
    required this.title,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onTap!,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryGray1,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.black : Colors.white,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Container(
              height: 12,
              width: 12,
              padding: EdgeInsets.all(2.4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Color(0xff3CD377) : Colors.white,
                border: Border.all(
                  color: selected ? Color(0xff3CD377) : Color(0xffBFBFBF),
                  width: 0.6,
                ),
              ),
              child: SvgPicture.asset(
                "assets/icons/white-tick.svg",
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            )
          ],
        ),
      ),
    );
  }
}
