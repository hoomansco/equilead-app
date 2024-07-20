import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class Birthday extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const Birthday({super.key, this.onNext, this.onBack});

  @override
  _BirthdayState createState() => _BirthdayState();
}

class _BirthdayState extends ConsumerState<Birthday> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.onboardScaffold,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.035),
                Container(
                  height: 56,
                  width: 56,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryGray1,
                  ),
                  child: SvgPicture.asset("assets/icons/star.svg"),
                ),
                SizedBox(height: size.height * 0.05),
                Text(
                  "When is your birthday?",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 56),
                SizedBox(
                  width: size.width,
                  height: size.height * 0.2,
                  child: CupertinoDatePicker(
                    backgroundColor: Colors.transparent,
                    mode: CupertinoDatePickerMode.date,
                    minimumYear: 1920,
                    maximumDate:
                        DateTime.now().subtract(Duration(days: 365 * 7)),
                    initialDateTime:
                        DateTime.now().subtract(Duration(days: 365 * 18)),
                    onDateTimeChanged: (DateTime value) {
                      _selectedDate = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: size.width * 0.9,
          child: Row(
            children: [
              PressEffect(
                onPressed: () {
                  widget.onBack!();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: SvgPicture.asset("assets/icons/arrow-left.svg"),
                ),
              ),
              Spacer(),
              PressEffect(
                onPressed: () {
                  var profile = ref.read(profileProvider.notifier);
                  profile.updateBirthday(_selectedDate);
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.onNext!();
                },
                child: Container(
                  width: 102,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Next',
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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
