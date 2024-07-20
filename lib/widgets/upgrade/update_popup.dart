import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePopup extends StatefulWidget {
  final bool canPop;
  const UpdatePopup({key, required this.canPop});

  @override
  State<UpdatePopup> createState() => _UpdatePopupState();
}

class _UpdatePopupState extends State<UpdatePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Size get size => MediaQuery.of(context).size;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          // Start animation at begin
        } else if (status == AnimationStatus.dismissed) {
          Navigator.of(context).pop();
          // To hide widget, we need complete animation first
        }
      });
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Container(
                  width: size.width * 0.9,
                  padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.03,
                      horizontal: size.width * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        child: !widget.canPop
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border:
                                          Border.all(color: Color(0xFFEBEBEB))),
                                  child: SvgPicture.asset(
                                      "assets/icons/close.svg"),
                                ),
                              )
                            : SizedBox(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/animated/ufo.png",
                              height: 40, width: 40),
                          SizedBox(height: size.height * 0.025),
                          Text(
                            "Are you ready ?",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.0125),
                          Text(
                            "It's time for an update to beam up the latest features and keep the fun rolling! Get ready to join the space party by tapping 'Update'",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff2E2E2E)),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.025),
                          PressEffect(
                            onPressed: () {
                              var url = "";
                              if (Platform.isAndroid) {
                                url =
                                    "https://play.google.com/store/apps/details?id=com.hoomans.equilead";
                              } else {
                                url =
                                    "https://apps.apple.com/in/app/the-hub-of-equilead/id6478268842";
                              }
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Update',
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
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
