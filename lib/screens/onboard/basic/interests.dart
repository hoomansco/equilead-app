import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/interests.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class Interests extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const Interests({super.key, this.onNext, this.onBack});

  @override
  _InterestsState createState() => _InterestsState();
}

class _InterestsState extends ConsumerState<Interests> {
  bool _isLoading = false;
  bool _isValid = false;

  List<Interest> allInterests =
      interests.map((e) => Interest.fromMap(e)).toList();
  List<Interest> selectedInterests = [];

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
            child: SingleChildScrollView(
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
                    child: SvgPicture.asset("assets/icons/telescope.svg"),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "Tell us about your area of interest?",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pick up 5 things you like',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff575757),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: size.width - 48,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: allInterests
                          .map(
                            (e) => GestureDetector(
                              onTap: selectedInterests.length >= 5 &&
                                      !e.selected
                                  ? null
                                  : () {
                                      setState(() {
                                        var i = allInterests.indexOf(e);
                                        allInterests[i].selected =
                                            !allInterests[i].selected;
                                        selectedInterests = allInterests
                                            .where(
                                                (element) => element.selected)
                                            .toList();
                                        if (selectedInterests.length >= 2 &&
                                            selectedInterests.length <= 5) {
                                          _isValid = true;
                                        } else {
                                          _isValid = false;
                                        }
                                      });
                                    },
                              child: InterestChip(interest: e),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 48),
                ],
              ),
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
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (_isValid) {
                    var profile = ref.read(profileProvider.notifier);
                    profile.updateInterests(
                        selectedInterests.map((e) => e.name).toList());
                    widget.onNext!();
                  }
                },
                child: Container(
                  width: 102,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: _isValid ? Colors.black : Color(0xffa3a3a3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _isValid ? Colors.black : Color(0xffa3a3a3),
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

class InterestChip extends StatelessWidget {
  final Interest interest;
  const InterestChip({
    super.key,
    required this.interest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: interest.selected ? Color(0xffF7F996) : AppColors.secondaryGray1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            interest.icon,
            height: 16,
            width: 16,
          ),
          SizedBox(width: 6),
          Text(
            interest.name.toUpperCase(),
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
