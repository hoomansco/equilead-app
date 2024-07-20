import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/checkin.dart';
import 'package:equilead/providers/checkin.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/checkin_successfully.dart';
import 'package:equilead/utils/notification_service.dart';
import 'package:equilead/widgets/access_location_popup.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/action_sheet.dart';
import 'package:equilead/widgets/common/checkin_chip.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/timezone.dart' as tz;

class SpaceCheckIn extends ConsumerStatefulWidget {
  SpaceCheckIn({super.key});

  @override
  _SpaceCheckInState createState() => _SpaceCheckInState();
}

class _SpaceCheckInState extends ConsumerState<SpaceCheckIn> {
  String selectedPurpose = '';
  bool? isMentor = false;
  String selectedDuration = '';
  bool canCheckIn = false;
  bool isLoading = false;
  List<String> duration = [
    '1 hr',
    '2 hr',
    '3 hr',
    '4 hr',
  ];
  bool _isValid = false;

  void setDurationIfStaff() {
    var profile = ref.read(profileProvider);
    if (profile.roleId == AppConstants.staffRoleId) {
      setState(() {
        duration = ['1 hr', '2 hr', '3 hr', '4 hr', '6 hr', '8 hr', '12 hr'];
      });
    }
  }

  void validate() {
    if (selectedPurpose.isNotEmpty &&
        isMentor != null &&
        selectedDuration.isNotEmpty) {
      setState(() {
        _isValid = true;
      });
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  static const platform = MethodChannel('app.hub.dev/openSettings');
  static const logChannel = MethodChannel('app.hub.dev/logs');

  @override
  void initState() {
    super.initState();
    setDurationIfStaff();
    checkIfAlreadyCheckedIn();
    logChannel.setMethodCallHandler((call) async {
      if (call.method == 'log') {
        print(call.arguments);
      }
    });
  }

  Future<void> checkIfAlreadyCheckedIn() async {
    var profile = ref.read(profileProvider);
    var checkedIn =
        await ref.read(checkInProvider.notifier).getCheckInData(profile.id!);
    setState(() {
      canCheckIn = !checkedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                IconWrapper(
                  icon: "assets/icons/back.svg",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 32),
                Text(
                  'What will you be working on?',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: size.width,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: purpose
                        .map((e) => CheckinChip(
                              title: e,
                              selected: e == selectedPurpose,
                              onTap: () {
                                setState(() {
                                  selectedPurpose = e;
                                });
                                validate();
                              },
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 48),
                Text(
                  'Time commitment',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: size.width,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: duration
                        .map((e) => CheckinChip(
                              title: e,
                              selected: e == selectedDuration,
                              onTap: () {
                                setState(() {
                                  selectedDuration = e;
                                });
                                validate();
                              },
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 48,
        child: PressEffect(
          onPressed: !isLoading
              ? _isValid
                  ? canCheckIn
                      ? () async {
                          var profile = ref.watch(profileProvider);
                          CheckIn checkIn = CheckIn(
                            checkInTime: DateTime.now(),
                            checkOutTime: DateTime.now().add(
                              Duration(
                                hours: duration.indexOf(selectedDuration) + 1,
                              ),
                            ),
                            purpose: selectedPurpose,
                            isMentor: isMentor!,
                            membershipId: profile.id,
                          );

                          var scheduleTime = DateTime.now().add(
                            Duration(
                              minutes:
                                  ((duration.indexOf(selectedDuration) + 1) *
                                          60) -
                                      15,
                            ),
                          );
                          tz.Location location = tz.local;
                          tz.TZDateTime scheduledDate =
                              tz.TZDateTime.from(scheduleTime, location);
                          // NotificationService().scheduleNotification(
                          //     scheduledNotificationDateTime: scheduledDate,
                          //     title: "Time's up! Check-out time is approaching",
                          //     body:
                          //         "To ensure that everyone gets the opportunity to use this space, we recommend not using it for more than 4 hours in a single day.");
                          var checkinProvider =
                              ref.read(checkInProvider.notifier);
                          var isSuccess =
                              await checkinProvider.createCheckIn(checkIn);
                          if (isSuccess) {
                            _showCheckInSuccessModal();
                          }
                        }
                      : showCheckinErrorModal
                  : () {}
              : () {},
          child: Container(
            width: size.width - 40,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isValid && canCheckIn ? Colors.black : Color(0xffa3a3a3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Text(
                    'Check-in',
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _showCheckInSuccessModal() async {
    Size size = MediaQuery.of(context).size;
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      elevation: 0,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
          color: Colors.transparent,
          child: Container(
            width: size.width - 32,
            padding: EdgeInsets.fromLTRB(20, 32, 20, 32),
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
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xff3CD377),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xffECFDF3),
                      width: 6,
                    ),
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/white-tick.svg",
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'You have successfully \nchecked in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xffE8F5FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Check-in',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.32,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            DateFormat('hh:mm a').format(ref
                                .watch(checkInProvider)
                                .checkInTime!
                                .toLocal()),
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.32,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Check-out',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.32,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            DateFormat('hh:mm a').format(ref
                                .watch(checkInProvider)
                                .checkOutTime!
                                .toLocal()),
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                PressEffect(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: size.width - 40,
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isValid ? Colors.black : Color(0xffa3a3a3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                PressEffect(
                  onPressed: () {
                    //TODO: add contribute button
                    // launchUrl(Uri.parse("https://www.tinkerhub.org/donate"));
                  },
                  child: Container(
                    width: size.width - 40,
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Contribute',
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Image.asset(
                            "assets/images/money-bag.png",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showCheckinErrorModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: CommonActionSheet(
          action: AppAction.Error,
          text: 'You might be already checked in.',
        ),
      ),
    );
  }
}
