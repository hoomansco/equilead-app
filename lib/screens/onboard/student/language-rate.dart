import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/providers/student.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/checkbox_group.dart';
import 'package:equilead/widgets/common/custom_radio.dart';

class LanguageRating extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const LanguageRating({super.key, this.onNext, this.onBack});

  @override
  _LanguageRatingState createState() => _LanguageRatingState();
}

class _LanguageRatingState extends ConsumerState<LanguageRating> {
  bool _isLoading = false;
  bool _isValid = false;

  List<dynamic> selectedLanguageRating = [];

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
                    "How would you rate yourself?",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 48),
                  SizedBox(
                    width: size.width * 0.9,
                    height: size.height * 0.54,
                    child: ListView.separated(
                      itemCount: ref.read(languageProvider).length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var langs = ref.read(languageProvider);
                        var langsProvider = ref.read(languageProvider.notifier);
                        return LanguageRatingWidget(
                          index: index,
                          lang: langs[index],
                          onChanged: (val) {
                            langsProvider.updateRating(index, val!);
                            setState(() {
                              _isValid =
                                  langs.every((element) => element.level != 0);
                            });
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Column(
                          children: [
                            SizedBox(height: 32),
                            Divider(
                              thickness: 1,
                              height: 1,
                              color: Color(0xffEBEBEB),
                            ),
                            SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                  )
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
                    var langs = ref.watch(languageProvider);
                    profile.updateSkills(langs);

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

class LanguageRatingWidget extends StatelessWidget {
  final int index;
  final CheckboxItem lang;
  final Function(int?)? onChanged;

  const LanguageRatingWidget({
    super.key,
    required this.index,
    required this.lang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Image.asset(lang.icon),
            ),
            SizedBox(width: 8),
            Text(
              lang.title,
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: lang.isSelected ? Colors.black : Color(0xff575757),
                height: 1,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Beginner',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff575757),
              ),
            ),
            SizedBox(width: 8),
            RadioButton(
              value: '1',
              groupValue: lang.level.toString(),
              onChanged: (val) => onChanged!(int.parse(val!)),
            ),
            Spacer(),
            Text(
              'Intermediate',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff575757),
              ),
            ),
            SizedBox(width: 8),
            RadioButton(
              value: '3',
              groupValue: lang.level.toString(),
              onChanged: (val) => onChanged!(int.parse(val!)),
            ),
            Spacer(),
            Text(
              'Advanced',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff575757),
              ),
            ),
            SizedBox(width: 8),
            RadioButton(
              value: '5',
              groupValue: lang.level.toString(),
              onChanged: (val) => onChanged!(int.parse(val!)),
            ),
          ],
        )
      ],
    );
  }
}
