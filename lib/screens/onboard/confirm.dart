import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/providers/college.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/onboard/setting_up.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/utils/utils.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/qr.dart';

class Confirm extends ConsumerStatefulWidget {
  final int invitedBy;
  final VoidCallback? onNext;
  final Function(int) onBack;
  const Confirm({
    super.key,
    this.onNext,
    required this.onBack,
    required this.invitedBy,
  });

  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends ConsumerState<Confirm> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var profile = ref.watch(profileProvider);
    var isSchoolStudent = ref.watch(schoolStudentProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xffEBEBEB),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.035),
                Container(
                  width: size.width,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MemCard(
                        profile: profile,
                        college: ref.watch(collegeNameProvider),
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MemberConfirmData(
                                  title: 'Age',
                                  value:
                                      "${getAge(DateTime.parse(profile.birthday!))} years old",
                                ),
                                SizedBox(width: 32),
                                MemberConfirmData(
                                  title: 'Gender',
                                  value: "${profile.sex}",
                                ),
                              ],
                            ),
                            profile.isStudent! && !isSchoolStudent
                                ? SizedBox(height: 24)
                                : SizedBox.shrink(),
                            profile.isStudent! && !isSchoolStudent
                                ? MemberConfirmData(
                                    title: 'Course',
                                    value: "${profile.course}",
                                  )
                                : SizedBox.shrink(),
                            profile.isStudent! && !isSchoolStudent
                                ? SizedBox(height: 24)
                                : SizedBox.shrink(),
                            profile.isStudent! && !isSchoolStudent
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      profile.stream == null
                                          ? SizedBox.shrink()
                                          : SizedBox(
                                              width: size.width * 0.4,
                                              child: MemberConfirmData(
                                                title: 'Stream',
                                                value:
                                                    "${capitalize(profile.stream == null ? "" : profile.stream!.toLowerCase())}",
                                              ),
                                            ),
                                      profile.stream == null
                                          ? SizedBox.shrink()
                                          : SizedBox(width: 24),
                                      MemberConfirmData(
                                        title: 'Year',
                                        value:
                                            "${profile.yearOfAdmission} - ${profile.yearOfGraduation}",
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
                SizedBox(height: 44),
                Container(
                  width: size.width,
                  height: 240,
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 40),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You won’t be able to change this information later.',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'This will be the information that will appear on all certificates issued by Equilead. ',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      PressEffect(
                        onPressed: () {
                          var userID = SharedPrefs().getUserID();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingUp(
                                invitedBy: widget.invitedBy,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: size.width * 0.9,
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Confirm',
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 0.85,
                                ),
                              ),
                              SizedBox(width: 4),
                              !_isLoading
                                  ? SvgPicture.asset("assets/icons/arrow-r.svg")
                                  : Container(
                                      padding: EdgeInsets.all(4),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      PressEffect(
                        onPressed: () {
                          var userID = SharedPrefs().getUserID();

                          widget.onBack(0);
                          context.pop();
                        },
                        child: Text(
                          'Change details'.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            height: 0.85,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemberConfirmData extends StatelessWidget {
  final String title;
  final String value;
  const MemberConfirmData({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff757575),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(0, -6),
              )
            ],
            color: Colors.transparent,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
            decorationColor: Color(0xffDEDEDE),
            decorationThickness: 1,
            height: 1.6,
          ),
        ),
        SizedBox(height: 2),
      ],
    );
  }
}

class MemCard extends ConsumerStatefulWidget {
  final Profile profile;
  final String college;
  const MemCard({
    super.key,
    required this.profile,
    required this.college,
  });

  @override
  _MemCardState createState() => _MemCardState();
}

class _MemCardState extends ConsumerState<MemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController? animationController;

  lottieAnimation() {
    animationController = AnimationController(vsync: this);
  }

  @override
  void initState() {
    super.initState();
    lottieAnimation();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var isSchoolStudent = ref.watch(schoolStudentProvider);
    return Container(
      height: size.width,
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Color(0xffC7AEE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expires on ${DateFormat('dd MMMM yyyy').format(DateTime.now().add(Duration(days: 365 * 2)))}',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.profile.uniqueId!.split('').join(' '),
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: QRCode(
                    size: size.width * 0.16,
                    data:
                        "https://app.tinkerhub.org/u/${widget.profile.uniqueId}",
                    avatar: "",
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 2),
          // TODO: add equilead animation marquee
          // SizedBox(
          //   width: double.infinity,
          //   child: Center(
          //     child: Lottie.asset(
          //       'assets/lottie/hub.json',
          //       repeat: true,
          //       frameRate: FrameRate(120),
          //       controller: animationController,
          //       onLoaded: (composition) {
          //         animationController!
          //           ..duration = composition.duration
          //           ..forward();
          //         animationController!.addListener(() {
          //           if (animationController!.isCompleted) {
          //             animationController!.repeat();
          //           }
          //         });
          //       },
          //     ),
          //   ),
          // ),
          Spacer(flex: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(widget.profile.avatar!),
                ),
                SizedBox(height: 16),
                Text(
                  widget.profile.name!.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.profile.isStudent!
                      ? isSchoolStudent
                          ? 'School Student'
                          : widget.college
                      : '${widget.profile.jobType != "Others" ? widget.profile.jobType : ""}${widget.profile.jobType != "Others" ? " at " : ''}${widget.profile.companyName}',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 1,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
