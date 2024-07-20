import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/theme/colors.dart';

class AccessAnimation extends StatefulWidget {
  final String action;
  final Function(String) onPopuPop;
  final bool isallow;
  const AccessAnimation(
      {super.key,
      required this.onPopuPop,
      required this.isallow,
      required this.action});

  @override
  State<AccessAnimation> createState() => _AccessAnimationState();
}

class _AccessAnimationState extends State<AccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Size get size => MediaQuery.of(context).size;
  static const platform = MethodChannel('app.hub.dev/openSettings');

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: ((details) {
        if (details.delta.dx >= 1) {
          _controller.reverse();
        }
      }),
      child: Column(
        children: [
          Spacer(),
          Align(
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/tinkerspace_map.png"),
                          SizedBox(height: size.height * 0.025),
                          Text(
                            widget.action == "toallow"
                                ? "Allow location access"
                                : "You can’t check-in",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.0125),
                          Text(
                            widget.action == "toallow"
                                ? "We use this to verify that you are at the TinkerSpace, Kochi.  We won't store your location. "
                                : "You can only check in while you're in the TinkerSpace.",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff2E2E2E)),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.02),
                          widget.action == "toallow"
                              ? Text(
                                  "To enter the space, you need to check in first. That way, we can make sure everything's smooth sailing. Plus, some cool features are locked until you check in!",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff2E2E2E)),
                                  textAlign: TextAlign.center,
                                )
                              : SizedBox.shrink(),
                          widget.action == "toallow"
                              ? SizedBox(height: size.height * 0.03)
                              : SizedBox.shrink(),
                          GestureDetector(
                            onTap: () async {
                              _controller.reverse();
                              if (widget.action == "toallow") {
                                if (widget.isallow) {
                                  widget.onPopuPop("allow");
                                } else {
                                  try {
                                    await platform
                                        .invokeMethod<int>('openSettingsApp');
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.015),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(32)),
                              child: Text(
                                widget.action == "toallow"
                                    ? (widget.isallow
                                        ? "Allow access"
                                        : "Go to settings")
                                    : "Ok",
                                style: TextStyle(
                                    color: Color(0xFFF2F2F2),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        ],
                      ),
                      Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _controller.reverse();
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Color(0xFFEBEBEB))),
                              child: SvgPicture.asset("assets/icons/close.svg"),
                            ),
                          )),
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
