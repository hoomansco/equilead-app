import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/providers/student.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/checkbox_group.dart';

class Languages extends ConsumerStatefulWidget {
  final Function(bool)? onNext;
  final VoidCallback? onBack;
  const Languages({super.key, this.onNext, this.onBack});

  @override
  _LanguagesState createState() => _LanguagesState();
}

class _LanguagesState extends ConsumerState<Languages> {
  bool _isLoading = false;
  bool _isSkip = true;
  bool _isValid = false;
  int numberOfSelected = 0;

  List<CheckboxItem> allLanguages = languages
      .map((e) => CheckboxItem(title: e['title'], icon: e['icon']))
      .toList();

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
                    child: SvgPicture.asset("assets/icons/code.svg"),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "Language you're familiar with",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select maximum of 5',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff575757),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: size.height * 0.44,
                    child: CheckboxGroup(
                      items: allLanguages,
                      onChanged: (index) {
                        if (numberOfSelected <= 4 ||
                            allLanguages[index].isSelected) {
                          setState(() {
                            allLanguages[index].isSelected =
                                !allLanguages[index].isSelected;
                            numberOfSelected = allLanguages
                                .where((element) => element.isSelected)
                                .length;
                            if (numberOfSelected <= 5) {
                              _isValid = true;
                            } else {
                              _isValid = false;
                            }
                            if (numberOfSelected > 0) {
                              _isSkip = false;
                            } else {
                              _isSkip = true;
                            }
                          });
                        } else {}
                      },
                    ),
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
                    var langs = ref.read(languageProvider.notifier);
                    profile.updateLanguages(
                        allLanguages.where((e) => e.isSelected).toList());
                    langs.selectedLanguages(
                        allLanguages.where((e) => e.isSelected).toList());

                    widget.onNext!(_isSkip);
                  }
                },
                child: Container(
                  width: 102,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: !_isSkip ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isSkip ? 'Skip' : 'Next',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 18,
                          color: _isSkip ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 0.85,
                        ),
                      ),
                      SizedBox(width: 4),
                      !_isLoading
                          ? SvgPicture.asset(
                              "assets/icons/arrow-r.svg",
                              height: 20,
                              width: 20,
                              colorFilter: ColorFilter.mode(
                                _isSkip ? Colors.black : Colors.white,
                                BlendMode.srcIn,
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(4),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation(
                                  _isSkip ? Colors.black : Colors.white,
                                ),
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
