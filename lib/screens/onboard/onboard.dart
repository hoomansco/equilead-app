import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/onboard/basic/avatar.dart';
import 'package:equilead/screens/onboard/basic/bio.dart';
import 'package:equilead/screens/onboard/basic/birthday.dart';
import 'package:equilead/screens/onboard/basic/email.dart';
import 'package:equilead/screens/onboard/basic/name.dart';
import 'package:equilead/screens/onboard/basic/sex.dart';
import 'package:equilead/screens/onboard/basic/student.dart';
import 'package:equilead/screens/onboard/confirm.dart';
import 'package:equilead/screens/onboard/student/college.dart';
import 'package:equilead/screens/onboard/student/course.dart';
import 'package:equilead/screens/onboard/student/district.dart';
import 'package:equilead/screens/onboard/basic/interests.dart';
import 'package:equilead/screens/onboard/student/language-rate.dart';
import 'package:equilead/screens/onboard/student/language.dart';
import 'package:equilead/screens/onboard/student/stream.dart';
import 'package:equilead/screens/onboard/student/year.dart';
import 'package:equilead/screens/onboard/work/company.dart';
import 'package:equilead/screens/onboard/work/job_type.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/shared_prefs.dart';

class OnboardScreen extends ConsumerStatefulWidget {
  final int invitedBy;
  const OnboardScreen({super.key, required this.invitedBy});

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  int onboardProgress = 0;

  @override
  void initState() {
    var userId = SharedPrefs().getUserID();
    var profile = ref.read(profileProvider.notifier);
    profile.setUserIdAndOrgId(int.parse(userId), int.parse(AppConstants.orgId));
    profile.updateInvitedBy(widget.invitedBy);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: AppColors.onboardScaffold,
          body: IndexedStack(
            index: onboardProgress,
            children: [
              Name(
                onBack: () {},
                onNext: () {
                  setState(() {
                    onboardProgress = 1;
                  });
                },
              ),
              Email(
                onBack: () {
                  setState(() {
                    onboardProgress = 0;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 2;
                  });
                },
              ),
              Birthday(
                onBack: () {
                  setState(() {
                    onboardProgress = 1;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 3;
                  });
                },
              ),
              Avatar(
                onBack: () {
                  setState(() {
                    onboardProgress = 2;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 4;
                  });
                },
              ),
              Sex(
                onBack: () {
                  setState(() {
                    onboardProgress = 3;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 5;
                  });
                },
              ),
              Bio(
                onBack: () {
                  setState(() {
                    onboardProgress = 4;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 6;
                  });
                },
              ),
              IsStudent(
                onNext: (val) {
                  setState(() {
                    var profile = ref.watch(profileProvider);
                    if (profile.isStudent!) {
                      if (val) {
                        onboardProgress = 12;
                      } else {
                        onboardProgress = 7;
                      }
                    } else {
                      onboardProgress = 15;
                    }
                  });
                },
              ),

              // Student Flow
              District(
                onBack: () {
                  setState(() {
                    onboardProgress = 6;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 8;
                  });
                },
              ),
              CollegeName(
                onBack: () {
                  setState(() {
                    onboardProgress = 7;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 9;
                  });
                },
              ),
              Course(
                onBack: () {
                  setState(() {
                    onboardProgress = 8;
                  });
                },
                onNext: (val) {
                  if (val) {
                    setState(() {
                      onboardProgress = 10;
                    });
                  } else {
                    setState(() {
                      onboardProgress = 11;
                    });
                  }
                },
              ),
              Stream(
                onBack: () {
                  setState(() {
                    onboardProgress = 9;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 11;
                  });
                },
              ),
              Year(
                onBack: () {
                  setState(() {
                    onboardProgress = 10;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 12;
                  });
                },
              ),
              Interests(
                onBack: () {
                  setState(() {
                    var isSchoolStudent = ref.watch(schoolStudentProvider);
                    if (isSchoolStudent) {
                      onboardProgress = 6;
                    } else {
                      onboardProgress = 11;
                    }
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 13;
                  });
                },
              ),
              Languages(
                onBack: () {
                  setState(() {
                    onboardProgress = 12;
                  });
                },
                onNext: (val) {
                  if (val) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Confirm(
                          invitedBy: widget.invitedBy,
                          onBack: (val) {
                            setState(() {
                              onboardProgress = val;
                            });
                          },
                        ),
                      ),
                    );
                  } else {
                    setState(() {
                      onboardProgress = 14;
                    });
                  }
                },
              ),
              LanguageRating(
                onBack: () {
                  setState(() {
                    onboardProgress = 13;
                  });
                },
                onNext: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Confirm(
                        invitedBy: widget.invitedBy,
                        onBack: (val) {
                          setState(() {
                            onboardProgress = val;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

              // Company Flow
              CompanyName(
                onBack: () {
                  setState(() {
                    onboardProgress = 6;
                  });
                },
                onNext: () {
                  setState(() {
                    onboardProgress = 16;
                  });
                },
              ),
              JobType(
                onBack: () {
                  setState(() {
                    onboardProgress = 15;
                  });
                },
                onNext: () async {
                  setState(() {
                    onboardProgress = 17;
                  });
                },
              ),
              Interests(
                onBack: () {
                  setState(() {
                    onboardProgress = 16;
                  });
                },
                onNext: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Confirm(
                        invitedBy: widget.invitedBy,
                        onBack: (val) {
                          setState(() {
                            onboardProgress = val;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
