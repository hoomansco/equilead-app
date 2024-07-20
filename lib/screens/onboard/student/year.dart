import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/text_validators.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/text_feild.dart';

class Year extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const Year({super.key, this.onNext, this.onBack});

  @override
  _YearState createState() => _YearState();
}

class _YearState extends ConsumerState<Year> {
  TextEditingController _aNameController = TextEditingController();
  TextEditingController _gNameController = TextEditingController();
  bool _isLoading = false;
  bool _isValid = false;
  int currentYear = DateTime.now().year;

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
                    child: SvgPicture.asset("assets/icons/calendar.svg"),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "Year of study",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 56),
                  OnboardTextField(
                    controller: _aNameController,
                    hintText: 'Year of admission',
                    keyboardType: TextInputType.number,
                    enableCapitalization: false,
                    onChanged: (p0) {
                      setState(() {
                        if (_aNameController.text.isValidNumber() &&
                            _gNameController.text.isValidNumber() &&
                            int.parse(_aNameController.text) <
                                int.parse(_gNameController.text) &&
                            int.parse(_aNameController.text) >=
                                currentYear - 8 &&
                            int.parse(_gNameController.text) <=
                                currentYear + 8) {
                          _isValid = true;
                        } else {
                          _isValid = false;
                        }
                      });
                    },
                  ),
                  OnboardTextField(
                    controller: _gNameController,
                    hintText: 'Year of graduation (expected)',
                    keyboardType: TextInputType.number,
                    enableCapitalization: false,
                    onChanged: (val) {
                      setState(() {
                        if (_aNameController.text.isValidNumber() &&
                            _gNameController.text.isValidNumber() &&
                            int.parse(_aNameController.text) <
                                int.parse(_gNameController.text) &&
                            int.parse(_aNameController.text) >=
                                currentYear - 8 &&
                            int.parse(_gNameController.text) <=
                                currentYear + 8) {
                          _isValid = true;
                        } else {
                          _isValid = false;
                        }
                      });
                    },
                  ),
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
                    profile.updateYears(int.parse(_aNameController.text),
                        int.parse(_gNameController.text));

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
