import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/providers/auth.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/vouch.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  MenuController controller = MenuController();
  FirebaseMessaging fcmessaging = FirebaseMessaging.instance;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Row(
                children: [
                  IconWrapper(
                    icon: "assets/icons/back.svg",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                  MenuAnchor(
                    controller: controller,
                    alignmentOffset: Offset(-50, 10),
                    style: MenuStyle(
                      alignment: AlignmentDirectional(-5, 1),
                      elevation: WidgetStateProperty.all(8),
                      backgroundColor: WidgetStateColor.resolveWith(
                        (states) => Colors.white,
                      ),
                      surfaceTintColor: WidgetStateColor.resolveWith(
                        (states) => Color(0xffebebeb),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Color(0xffEBEBEB),
                            width: 0.4,
                          ),
                        ),
                      ),
                      shadowColor: WidgetStateColor.resolveWith(
                        (states) => Colors.black.withOpacity(0.2),
                      ),
                    ),
                    consumeOutsideTap: true,
                    builder: (context, controller, child) => IconWrapper(
                        icon: "assets/icons/horizontal-dots.svg",
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        }),
                    menuChildren: [
                      MenuItemButton(
                        child: SettingsOption(
                          onPressed: () async {
                            controller.close();
                            await _showDeleteConfirm();
                          },
                          title: 'Delete account',
                          icon: "assets/icons/trash.svg",
                          color: Color(0xffD92D20),
                        ),
                      ),
                      SizedBox(height: 4),
                      Divider(
                        height: 0.4,
                        color: Color(0xffEBEBEB),
                        thickness: 0.4,
                      ),
                      SizedBox(height: 4),
                      MenuItemButton(
                        child: SettingsOption(
                          onPressed: () async {
                            controller.close();
                            await _showLogoutConfirm();
                          },
                          title: 'Log out',
                          icon: "assets/icons/logout.svg",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 48),
              SettingsOption(
                onPressed: () async {
                  launchUrl(
                    Uri.parse('https://www.tinkerhub.org/Hub/T&C'),
                  );
                },
                title: 'Terms and conditions',
                icon: "assets/icons/terms.svg",
              ),
              SizedBox(height: 16),
              Divider(
                height: 0.4,
                color: Color(0xffEBEBEB),
                thickness: 0.4,
              ),
              SizedBox(height: 16),
              SettingsOption(
                onPressed: () {
                  launchUrl(
                    Uri.parse('https://www.tinkerhub.org/hub/Privacy_Policy'),
                  );
                },
                title: 'Privacy policy',
                icon: "assets/icons/lock.svg",
              ),
              SizedBox(height: 16),
              Divider(
                height: 0.4,
                color: Color(0xffEBEBEB),
                thickness: 0.4,
              ),
              SizedBox(height: 16),
              SettingsOption(
                onPressed: () {
                  launchUrl(
                    Uri.parse('https://www.tinkerhub.org/community-guidlines'),
                  );
                },
                title: 'Community guidelines',
                icon: "assets/icons/shield2.svg",
              ),
              SizedBox(height: 32),
              PressEffect(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VouchPage(),
                    ),
                  );
                },
                child: Container(
                  width: size.width - 40,
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vouch your  friends',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Let's grow our community together!",
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        height: 48,
                        width: 48,
                        child: Stack(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: Color(0xffFFF73A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset("assets/images/animated/clap.png"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Center(
                child: Text(
                  'Version ${AppConstants.version}',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff757575),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Center(
                child: PressEffect(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    launchUrl(Uri.parse('https://hoomans.dev/'));
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Made with ❤️ by',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff757575),
                      ),
                      children: [
                        TextSpan(
                          text: '  hoomans co.',
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future _showLogoutConfirm() async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Time for a Pause?',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Pick up right where you left off when you return.",
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff2E2E2E),
                  letterSpacing: -0.2,
                  height: 1.32,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  PressEffect(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      var authRef = ref.read(authProvider.notifier);
                      var profileRef = ref.read(profileProvider.notifier);
                      var profile = ref.read(profileProvider);
                      await fcmessaging
                          .unsubscribeFromTopic(profile.userId.toString());

                      context.pushReplacement('/auth');
                      authRef.logout();
                      profileRef.logout();
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                        color: Colors.black,
                      ),
                      child: Text(
                        'LOGOUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'General Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  PressEffect(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'GO BACK',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'General Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showDeleteConfirm() async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete account?',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "All data related to this profile will be completely deleted.",
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff2E2E2E),
                  letterSpacing: -0.2,
                  height: 1.32,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  PressEffect(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      var authRef = ref.read(authProvider.notifier);
                      var profileRef = ref.read(profileProvider.notifier);
                      await profileRef.deleteProfile();
                      context.pop(context);
                      context.pushReplacement('/auth');
                      authRef.logout();
                      profileRef.logout();
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.red,
                          width: 0.5,
                        ),
                        color: Colors.red,
                      ),
                      child: Text(
                        'DELETE',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'General Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  PressEffect(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'GO BACK',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'General Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final String icon;
  final Color? color;
  const SettingsOption({
    super.key,
    required this.onPressed,
    required this.title,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onPressed,
      child: Row(
        children: [
          SvgPicture.asset(icon),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color ?? Color(0xff2e2e2e),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
