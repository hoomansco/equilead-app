import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/checkin.dart';
import 'package:equilead/screens/hygiene_check.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/remote_config.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckinSuccessfully extends StatefulWidget {
  final CheckIn checkIn;
  const CheckinSuccessfully({super.key, required this.checkIn});

  @override
  State<CheckinSuccessfully> createState() => _CheckinSuccessfullyState();
}

class _CheckinSuccessfullyState extends State<CheckinSuccessfully> {
  Size get size => MediaQuery.of(context).size;
  late Timer _timer;
  List _contacts = RemoteConfig().getCheckinContacts();
  Map wifiInfo = RemoteConfig().getWifiInfo();
  bool isCopied = false;
  int seconds = 0;
  int _remainingSeconds = 0;

  @override
  void initState() {
    seconds =
        (widget.checkIn.checkOutTime!.difference(DateTime.now()).inSeconds);
    _remainingSeconds = seconds;
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer =
        Timer.periodic(Duration(seconds: 1), (Timer t) => _getCurrentTime());
  }

  void _getCurrentTime() {
    if (_remainingSeconds > 0) {
      setState(() {
        _remainingSeconds--;
      });
    } else {
      _timer.cancel();
    }
  }

  String formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                right: size.width * 0.05,
                bottom: size.height * 0.03,
              ),
              width: double.infinity,
              decoration: BoxDecoration(color: Color(0xFF884BD4)),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  SizedBox(height: 16),
                  Container(
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/animated/celeb.png",
                          height: 40,
                          width: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "You have been",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "Checked-in successfully".toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        IconWrapper(
                          icon: "assets/icons/close.svg",
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDuration(_remainingSeconds),
                          style: TextStyle(
                            fontFamily: "General Sans",
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Check-out before ",
                            children: [
                              TextSpan(
                                text: DateFormat('hh:mm a').format(
                                    widget.checkIn.checkOutTime!.toLocal()),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                          style: TextStyle(
                            color: Color(0xFF2E2E2E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "We recommend not using for more than 4 hours in a single day",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.secondaryGray1),
              child: Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/wifi.svg",
                      width: 20,
                      height: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${wifiInfo["name"]}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: wifiInfo["password"],
                        ),
                      );
                      setState(() {
                        isCopied = true;
                      });
                      Future.delayed(Duration(milliseconds: 1500), () {
                        setState(() {
                          isCopied = false;
                        });
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${wifiInfo["password"]}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            height: 14,
                            width: 14,
                            child: isCopied
                                ? SvgPicture.asset(
                                    "assets/icons/white-tick.svg",
                                    colorFilter: ColorFilter.mode(
                                      Color(0xFF3CD377),
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : SvgPicture.asset("assets/icons/copy.svg"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HygieneCheckScreen()));
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: size.height * 0.02,
                ),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/icons/hygiene.svg"),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hygiene Checklist",
                          style: TextStyle(
                            fontFamily: "General Sans",
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Housekeeping rules you should know",
                          style: TextStyle(
                            color: Color(0xFF2E2E2E),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                    Spacer(),
                    SvgPicture.asset("assets/icons/chevron-right.svg")
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5FE),
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "We don't charge for using \nTinkerSpace",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "General Sans",
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "This space is run with kind contribution from people like you. We would recommend you  making a small donation.",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse("https://www.tinkerhub.org/donate"));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.008,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Contribute".toUpperCase()),
                          SizedBox(width: 5),
                          SvgPicture.asset("assets/icons/money_bag.svg")
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Text(
                "Things you can explore here",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "General Sans",
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              height: 185,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: thingsToExplore
                    .map(
                      (ele) => ThingsToExplore(
                        iconUrl: ele["iconUrl"]!,
                        title: ele["title"]!,
                        subtitle: ele["subtitle"]!,
                        color: Color(int.parse(ele["color"]!)),
                        isLast: ele["title"] == thingsToExplore.last["title"],
                      ),
                    )
                    .toList(),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: size.height * 0.04, horizontal: size.width * 0.05),
              child: Text(
                "People here to help you ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              children: _contactsWidgets(),
            ),
            SizedBox(height: size.height * 0.05)
          ],
        ),
      ),
    );
  }

  List<Widget> _contactsWidgets() {
    List<Widget> _list = [];
    for (var i = 0; i < _contacts.length; i++) {
      _list.add(GestureDetector(
        onTap: () {
          launchUrl(
            Uri.parse("https://wa.me/${_contacts[i]["mobile"]!}"),
            mode: LaunchMode.externalApplication,
          );
        },
        child: Container(
          width: size.width,
          margin: EdgeInsets.symmetric(
              horizontal: size.width * 0.05, vertical: size.height * 0.015),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(_contacts[i]["avatar"]),
              ),
              SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _contacts[i]["name"]!,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    _contacts[i]["subtitle"]!,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black)),
                child: Text(
                  'Contact'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return _list;
  }
}

class ThingsToExplore extends StatelessWidget {
  const ThingsToExplore({
    super.key,
    required this.iconUrl,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLast = false,
  });

  final String iconUrl;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: 200,
      margin: EdgeInsets.only(left: 20, right: isLast ? 24 : 4),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFEBEBEB)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconUrl,
            height: 60,
            width: 60,
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            subtitle,
            style: TextStyle(
                color: Color(0xFF2E2E2E),
                fontSize: 12,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
