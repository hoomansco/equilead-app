import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/models/user.dart';
import 'package:equilead/providers/auth.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/onboard/check_vouch.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/screens/main/navigation.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/utils/toast.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/otp_pin.dart';
import 'package:equilead/widgets/common/toast.dart';

class Authentication extends ConsumerStatefulWidget {
  const Authentication({super.key});

  @override
  AuthenticationState createState() => AuthenticationState();
}

class AuthenticationState extends ConsumerState<Authentication> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isOTP = false;
  bool _isValid = false;
  String countryCode = "+91";

  @override
  void initState() {
    super.initState();
  }

  void sendOTP() async {
    setState(() {
      _isLoading = true;
    });
    if (_phoneController.text.length == 10) {
      var res = await NetworkUtils().httpPost("user/otp", {
        "phoneNumber": '${countryCode}${_phoneController.text}',
      });
      print(res);
      if (res?.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _isOTP = true;
        });
      } else {
        // show toast to show otp error
        showAppToast(context, "Failed to send OTP", ToastType.error);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void verifyOTP() async {
    setState(() {
      _isLoading = true;
    });
    if (_otpController.text.length == 4) {
      var res = await NetworkUtils().httpPost("user/otp/verify", {
        "phoneNumber": '${countryCode}${_phoneController.text}',
        "otp": _otpController.text,
      });

      if (res?.statusCode == 200) {
        User user = User.fromRawJson(res!.body);
        var access = jsonDecode(res.body)['token'];
        var refresh = jsonDecode(res.body)['refreshToken'] ?? "";
        await ref
            .read(authProvider.notifier)
            .login(user, access, refresh)
            .then((value) async {
          // fetch user profile
          var profile =
              await ref.read(profileProvider.notifier).getProfile(user.id!);
          print(profile.id);
          print(profile.name);
          setState(() {
            _isLoading = false;
          });
          if (profile.id != null && profile.isOnboard!) {
            SharedPrefs().setMemberID(profile.id!.toString());
            ref
                .read(schoolStudentProvider.notifier)
                .update(profile.isStudent! && profile.subOrgId == null);
            SharedPrefs().setStudentStatus(profile.isStudent!).then((value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainNavigation(),
                ),
              );
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckVouch(),
              ),
            );
          }
        });
      } else {
        // show toast to show otp error
        showAppToast(context, "Invalid OTP", ToastType.error);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showAppToast(context, "Invalid OTP", ToastType.error);
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: AppColors.onboardScaffold,
          resizeToAvoidBottomInset: true,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isOTP ? _enterOTP(size) : _enterPhone(size),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: SizedBox(
            width: size.width - 48,
            child: Row(
              children: [
                _isOTP
                    ? PressEffect(
                        onPressed: !_isValid
                            ? () {}
                            : () {
                                sendOTP();
                                showAppToast(
                                  context,
                                  "Code resend",
                                  ToastType.info,
                                );
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Didn’t get a code? resend'.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                Spacer(),
                PressEffect(
                  onPressed: !_isValid
                      ? () {}
                      : _isLoading
                          ? () => null
                          : () {
                              _isOTP ? verifyOTP() : sendOTP();
                            },
                  child: Container(
                    width: 102,
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? Colors.black.withOpacity(0.9)
                          : !_isOTP
                              ? !_isValid
                                  ? Color(0xffa3a3a3)
                                  : Colors.black
                              : _otpController.text.length != 4
                                  ? Color(0xffa3a3a3)
                                  : Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _isLoading
                            ? Colors.black.withOpacity(0.9)
                            : !_isOTP
                                ? !_isValid
                                    ? Color(0xffa3a3a3)
                                    : Colors.black
                                : _otpController.text.length != 4
                                    ? Color(0xffa3a3a3)
                                    : Colors.black,
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
      ),
    );
  }

  Column _enterPhone(Size size) {
    return Column(
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
          child: SvgPicture.asset("assets/icons/phone.svg"),
        ),
        SizedBox(height: size.height * 0.05),
        Text(
          "What's your phone number?",
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w500,
            height: 1.32,
          ),
        ),
        SizedBox(height: size.height * 0.05),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '🇮🇳',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w400,
                      color: Color(0xffA3B0D7),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.32,
                      letterSpacing: size.width * 0.004,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
              width: size.width * 0.55,
              child: TextField(
                controller: _phoneController,
                scrollPadding: EdgeInsets.zero,
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w500,
                  letterSpacing: size.width * 0.006,
                  height: 1.32,
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 10,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  focusedBorder: InputBorder.none,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  enabledBorder: InputBorder.none,
                  counterText: "",
                ),
                onChanged: (value) {
                  if (value.length == 10) {
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
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'We will send you a verification code to your phone.',
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 14,
            color: Color(0xff575757),
          ),
        ),
      ],
    );
  }

  Column _enterOTP(Size size) {
    return Column(
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
          child: SvgPicture.asset("assets/icons/shield.svg"),
        ),
        SizedBox(height: size.height * 0.05),
        Text(
          "Enter your verification code",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w600,
            height: 1.32,
          ),
        ),
        SizedBox(height: size.height * 0.04),
        TextFieldPin(
          autoFocus: true,
          textController: _otpController,
          onChange: (c) async {
            _otpController.text = c;
            setState(() {
              _otpController.text = c;
            });
            if (c.length == 4) {
              verifyOTP();
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          defaultBoxSize: size.width * 0.11,
          margin: size.width * 0.065,
          codeLength: 4,
          textStyle: const TextStyle(
            fontFamily: 'General Sans',
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Send to ${_phoneController.text}',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 14,
                color: Color(0xffA3A3A3),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            PressEffect(
              onPressed: () {
                _otpController.clear();
                setState(() {
                  _isOTP = false;
                });
              },
              child: Text(
                'Edit',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.032),
      ],
    );
  }
}
