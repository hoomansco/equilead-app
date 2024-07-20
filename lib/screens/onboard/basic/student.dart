import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/radio_group.dart';

class IsStudent extends ConsumerStatefulWidget {
  final Function(bool)? onNext;
  const IsStudent({super.key, this.onNext});

  @override
  _IsStudentState createState() => _IsStudentState();
}

class _IsStudentState extends ConsumerState<IsStudent> {
  String _selected = '';
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
                  child: SvgPicture.asset("assets/icons/pen.svg"),
                ),
                SizedBox(height: size.height * 0.05),
                Text(
                  "What do you do?",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 56),
                RadioGroup(
                  items: [
                    'Student',
                    'Professional',
                    'Others',
                  ],
                  selected: _selected,
                  onChanged: (value) {
                    setState(() {
                      _selected = value!;
                    });
                  },
                )
              ],
            ),
          ),
        ),
        floatingActionButton: PressEffect(
          onPressed: () {
            if (_selected.isNotEmpty) {
              var profile = ref.read(profileProvider.notifier);
              profile.updateStudentStatus(_selected == 'Student');
              SharedPrefs().setStudentStatus(_selected == 'Student');
              ref
                  .watch(schoolStudentProvider.notifier)
                  .update(_selected == 'Student');
              if (_selected == 'Student') {
                profile.updateCollegeName(AppConstants.defaultStudentSubOrg);
              } else {
                profile.updateCollegeName(null);
              }

              widget.onNext!(_selected == 'Student');
            }
          },
          child: Container(
            width: 102,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: _selected.isNotEmpty ? Colors.black : Color(0xffa3a3a3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _selected.isNotEmpty ? Colors.black : Color(0xffa3a3a3),
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
                          valueColor: AlwaysStoppedAnimation(Colors.white),
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
