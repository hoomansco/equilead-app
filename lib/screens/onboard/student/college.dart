import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/providers/college.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/radio_group.dart';
import 'package:equilead/widgets/common/text_feild.dart';

class CollegeName extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const CollegeName({
    super.key,
    this.onNext,
    this.onBack,
  });

  @override
  _CollegeNameState createState() => _CollegeNameState();
}

class _CollegeNameState extends ConsumerState<CollegeName> {
  TextEditingController _collegeNameController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  int _selectedId = 0;
  String _selectedName = '';

  @override
  void initState() {
    getColleges();
    super.initState();
  }

  getColleges() async {
    var cp = ref.read(collegeProvider.notifier);
    await cp.getColleges();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var cp = ref.read(collegeDistrictProvider.notifier);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.onboardScaffold,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              controller: _scrollController,
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
                    child: SvgPicture.asset("assets/icons/college.svg"),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "Select your college",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 56),
                  OnboardTextField(
                    controller: _collegeNameController,
                    hintText: 'College Name',
                    keyboardType: TextInputType.name,
                    isEnabled: true,
                    enableCapitalization: false,
                    prefixIcon: 'assets/icons/search-l.svg',
                    onChanged: (value) {
                      cp.searchColleges(value.toLowerCase());
                    },
                    onTap: () {
                      _scrollController.animateTo(
                        size.height * 0.2,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: size.height * 0.44,
                    child: RadioGroup(
                      items: ref
                          .watch(collegeDistrictProvider)
                          .map((e) => e.name!)
                          .toList(),
                      selected: _selectedName,
                      onChanged: (value) {
                        setState(() {
                          _selectedName = value!;
                          _selectedId = ref
                              .watch(collegeDistrictProvider)
                              .firstWhere((element) => element.name == value)
                              .id!;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 32),
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
                  if (_selectedName.isNotEmpty) {
                    var profile = ref.read(profileProvider.notifier);
                    profile.updateCollegeName(_selectedId);

                    ref
                        .read(collegeNameProvider.notifier)
                        .update(_selectedName);

                    widget.onNext!();
                  }
                },
                child: Container(
                  width: 102,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color:
                        _selectedName != '' ? Colors.black : Color(0xffa3a3a3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _selectedName != ''
                          ? Colors.black
                          : Color(0xffa3a3a3),
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

  // Future<void> _showCollegePicker() async {
  //   Size size = MediaQuery.of(context).size;
  //   return await showModalBottomSheet(
  //     elevation: 0,
  //     backgroundColor: Colors.transparent,
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (newContext, setModalState) {
  //         return Container(
  //           height: size.height * 0.6,
  //           width: size.width,
  //           color: Colors.transparent,
  //           padding: EdgeInsets.all(24),
  //           child: Container(
  //             padding: EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: AppColors.onboardScaffold,
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             child: Column(
  //               children: [
  //                 OnboardTextField(
  //                   controller: _cSearchNameController,
  //                   hintText: 'Search College',
  //                   keyboardType: TextInputType.name,
  //                   enableCapitalization: true,
  //                 ),
  //                 SizedBox(height: 8),
  //                 SizedBox(
  //                   height: size.height * 0.38,
  //                   width: size.width,
  //                   child: ListView.builder(
  //                     itemCount: _colleges.length,
  //                     itemBuilder: (context, index) {
  //                       return RadioGroup(
  //                         items: _colleges.map((e) => e.name!).toList(),
  //                         selected: _selectedName,
  //                         onChanged: (value) {
  //                           setModalState(() {
  //                             _selectedName = value!;
  //                             _cNameController.text = value;
  //                           });
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
