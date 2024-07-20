import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/screens/main/space.dart';

class CrowdedSpace extends StatelessWidget {
  final CrowdStatus status;
  const CrowdedSpace({super.key, this.status = CrowdStatus.free});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          status == CrowdStatus.free
              ? "assets/icons/green-arrow-l-bottom.svg"
              : status == CrowdStatus.crowded
                  ? "assets/icons/red-arrow-r-top.svg"
                  : "assets/icons/orange-arrow-r-top.svg",
        ),
        SizedBox(width: 4),
        Text(
          status == CrowdStatus.free
              ? "Free than usual"
              : status == CrowdStatus.crowded
                  ? "Very crowded. An event? 🧐"
                  : "Crowded than usual", // Free than usual
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
