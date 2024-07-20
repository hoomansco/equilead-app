import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/utils/toast.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/text_feild.dart';
import 'package:equilead/widgets/common/toast.dart';

class Name extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const Name({super.key, this.onNext, this.onBack});

  @override
  _NameState createState() => _NameState();
}

class _NameState extends ConsumerState<Name> {
  TextEditingController _fNameController = TextEditingController();
  TextEditingController _lNameController = TextEditingController();
  bool _isLoading = false;
  bool _isValid = false;
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
                    child: SvgPicture.asset("assets/icons/user.svg"),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "What’s your name?",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 56),
                  OnboardTextField(
                    controller: _fNameController,
                    hintText: 'First Name',
                    keyboardType: TextInputType.text,
                    enableCapitalization: true,
                    onChanged: (p0) {
                      if (_lNameController.text.length >= 1 &&
                          _fNameController.text.length >= 3) {
                        setState(() {
                          _isValid = true;
                        });
                      } else {
                        setState(() {
                          _isValid = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  OnboardTextField(
                    controller: _lNameController,
                    hintText: 'Last Name',
                    keyboardType: TextInputType.text,
                    enableCapitalization: true,
                    onChanged: (p0) {
                      if (_lNameController.text.length >= 1 &&
                          _fNameController.text.length >= 3) {
                        setState(() {
                          _isValid = true;
                        });
                      } else {
                        setState(() {
                          _isValid = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0x338BCDF8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Please enter your official name.",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'General Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.42,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "This is the name that will appear on all sections of the app. You cannot change this later.",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'General Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.42,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: PressEffect(
          onPressed: () {
            if (_lNameController.text.trim().length < 1) {
              showAppToast(
                  context, 'Please enter your last name', ToastType.error);
              return;
            }
            FocusManager.instance.primaryFocus?.unfocus();
            if (_fNameController.text.trim().length < 2) {
              showAppToast(context, 'Please a your name', ToastType.error);
              return;
            } else {
              var profile = ref.read(profileProvider.notifier);
              profile.updateProfileName(
                  '${_fNameController.text.trim()} ${_lNameController.text.trim()}');

              var userID = SharedPrefs().getUserID();

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
