import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/text_validators.dart';
import 'package:equilead/utils/toast.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/text_feild.dart';
import 'package:equilead/widgets/common/toast.dart';

class Email extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const Email({super.key, this.onNext, this.onBack});

  @override
  _EmailState createState() => _EmailState();
}

class _EmailState extends ConsumerState<Email> {
  TextEditingController _emailController = TextEditingController();
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
                  child: SvgPicture.asset("assets/icons/email.svg"),
                ),
                SizedBox(height: size.height * 0.05),
                Text(
                  "What’s  your email ID ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 56),
                OnboardTextField(
                  controller: _emailController,
                  hintText: 'Enter you email',
                  keyboardType: TextInputType.emailAddress,
                  enableCapitalization: false,
                  onChanged: (p0) {
                    setState(() {
                      _isValid = p0.isValidEmail();
                    });
                  },
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
                  if (!_emailController.text.isValidEmail()) {
                    showAppToast(
                        context, 'Please enter a valid email', ToastType.error);
                    return;
                  } else {
                    var profile = ref.read(profileProvider.notifier);
                    profile.updateProfileEmail(_emailController.text);
                    widget.onNext!();
                  }
                  FocusManager.instance.primaryFocus?.unfocus();
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
