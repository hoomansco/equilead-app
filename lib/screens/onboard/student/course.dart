import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/providers/student.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/radio_group.dart';
import 'package:equilead/widgets/common/text_feild.dart';

class Course extends ConsumerStatefulWidget {
  final Function(bool)? onNext;
  final VoidCallback? onBack;
  const Course({super.key, this.onNext, this.onBack});

  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends ConsumerState<Course> {
  TextEditingController _searchController = TextEditingController();
  String _selected = '';
  String _selectedType = '';
  bool _isLoading = false;
  List<String> allCourses = courses.values.toList();
  List<String> sCourses = courses.values.toList();

  void searchCourse() {
    setState(() {
      sCourses = allCourses
          .where((c) =>
              c.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

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
                    child: SvgPicture.asset("assets/icons/course.svg"),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "Select your course",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 56),
                  OnboardTextField(
                    controller: _searchController,
                    hintText: 'Course',
                    keyboardType: TextInputType.text,
                    enableCapitalization: true,
                    prefixIcon: 'assets/icons/search-l.svg',
                    onChanged: (value) {
                      searchCourse();
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.44,
                    child: RadioGroup(
                      items: sCourses,
                      selected: _selected,
                      onChanged: (value) {
                        setState(() {
                          _selected = value!;
                          _selectedType = courses.keys
                              .firstWhere((key) => courses[key] == value);
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 56),
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
                  if (_selected.isNotEmpty) {
                    var profile = ref.read(profileProvider.notifier);
                    var streamP = ref.read(streamProvider.notifier);
                    streamP.filterStreamByCourse(_selectedType);
                    profile.updateCourse(_selected);
                    var stream = ref.read(streamProvider);

                    if (stream.isEmpty) {
                      profile.updateStream(null);
                      widget.onNext!(false);
                    } else {
                      widget.onNext!(true);
                    }
                  }
                },
                child: Container(
                  width: 102,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: _selected != '' ? Colors.black : Color(0xffa3a3a3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _selected != '' ? Colors.black : Color(0xffa3a3a3),
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
