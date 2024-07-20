import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

enum AppAction { Success, Error }

class CommonActionSheet extends StatelessWidget {
  final AppAction action;
  final String text;
  const CommonActionSheet({
    super.key,
    required this.action,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56,
            width: 56,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: action == AppAction.Success
                  ? Color(0xff3CD377)
                  : Color(0xffFF0000),
              shape: BoxShape.circle,
              border: Border.all(
                color: action == AppAction.Success
                    ? Color(0xffECFDF3)
                    : Color(0xffFDECEC),
                width: 6,
              ),
            ),
            child: SvgPicture.asset(
              action == AppAction.Success
                  ? "assets/icons/white-tick.svg"
                  : "assets/icons/white-cross.svg",
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.32,
            ),
          ),
          SizedBox(height: 32),
          PressEffect(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
