import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/screens/can_vouch.dart';
import 'package:equilead/screens/onboard/onboard.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckVouch extends StatefulWidget {
  const CheckVouch({super.key});

  @override
  State<CheckVouch> createState() => _CheckVouchState();
}

class _CheckVouchState extends State<CheckVouch> {
  String vouchedBy = '';
  int vouchedById = 0;
  bool _isLoading = true;
  bool _isVouched = false;
  int numberOfRetry = 0;

  @override
  void initState() {
    getVouchStatus();
    super.initState();
  }

  Future<void> getVouchStatus() async {
    var phoneNumber = SharedPrefs().getPhoneNumber();
    var resp = await NetworkUtils().httpGet('invite/$phoneNumber');
    if (resp?.statusCode == 200) {
      var data = resp?.body;
      if (data != null) {
        setState(() {
          _isVouched = true;
          vouchedBy = jsonDecode(data)['inviterName'];
          vouchedById = jsonDecode(data)['inviterMembershipId'];
        });
      }
    } else {
      setState(() {
        _isVouched = false;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.035),
                        Container(
                          height: 104,
                          width: 104,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffFFF73A),
                          ),
                          child: Image.asset(
                            _isVouched
                                ? "assets/images/animated/clap.png"
                                : "assets/images/animated/finger-cross.png",
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                        Text(
                          _isVouched
                              ? '$vouchedBy vouched you!'
                              : "You need a vouch!",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'General Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.32,
                          ),
                        ),
                        SizedBox(height: 8),
                        _isVouched
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: Row(
                                  children: [
                                    Text(
                                      'Read the Community ',
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 16,
                                        height: 1,
                                      ),
                                    ),
                                    _isVouched
                                        ? PressEffect(
                                            onPressed: () {
                                              launchUrl(
                                                Uri.parse(
                                                    'https://www.tinkerhub.org/community-guidlines'),
                                              );
                                            },
                                            child: Text(
                                              'guidelines'.toUpperCase(),
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                height: 1.5,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    _isVouched
                                        ? SvgPicture.asset(
                                            "assets/icons/arrow-top-right.svg")
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              )
                            : SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
                          decoration: BoxDecoration(
                            color: Color(0x338BCDF8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _isVouched
                                  ? SizedBox.shrink()
                                  : Text(
                                      "Getting vouched connects you to Equilead's skilled network and adds credibility to your profile from day one.",
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                              _isVouched
                                  ? Text(
                                      "Being vouched verifies you are a trustworthy community member.",
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: Text(
                                        "To become a Equilead member, you'll need to be vouched by someone already in the community. Here's how:",
                                        style: TextStyle(
                                          fontFamily: 'General Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                              _isVouched
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "'Vouched by'",
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  " information will display on your public profile.",
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                height: 1.2,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 8),
                                      child: Text(
                                        "1. Ask a friend who is a Equilead member to vouch for you. \n2. This 'Vouched By' information will display on your public profile.",
                                        style: TextStyle(
                                          fontFamily: 'General Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                              _isVouched
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(
                                        "Being vouched verifies you are a trustworthy community member from the start.",
                                        style: TextStyle(
                                          fontFamily: 'General Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(
                                        "Being vouched verifies you are a trustworthy community member from the start. Request a vouch today to get full access!",
                                        style: TextStyle(
                                          fontFamily: 'General Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(height: 132),
                      ],
                    ),
                  ),
          ),
        ),
        floatingActionButton: _isVouched
            ? PressEffect(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          OnboardScreen(invitedBy: vouchedById),
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  width: size.width - 40,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lets go',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      SvgPicture.asset(
                        "assets/icons/arrow-right-w.svg",
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  PressEffect(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ContactCanVouch(),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: size.width - 40,
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Need vouch?',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  PressEffect(
                    onPressed: () {
                      if (numberOfRetry < 3) {
                        setState(() {
                          _isLoading = true;
                          numberOfRetry++;
                        });
                        getVouchStatus();
                      }
                    },
                    child: Container(
                      height: 40,
                      width: size.width - 40,
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        "I've an invite now. Retry.",
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
