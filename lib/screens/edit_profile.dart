import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/interests.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/onboard/basic/interests.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';

class EditProfile extends ConsumerStatefulWidget {
  final VoidCallback? onPop;
  const EditProfile({super.key, this.onPop});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  TextEditingController twitterController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController githubController = TextEditingController();
  List<Interest> allInterests =
      interests.map((e) => Interest.fromMap(e)).toList();
  List<Interest> selectedInterests = [];

  bool _isValid = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    updateProfileWithLinks();
    // getSocials();
    getSelectedInterests();
  }

  @override
  void dispose() {
    twitterController.dispose();
    linkedinController.dispose();
    githubController.dispose();
    super.dispose();
  }

  void updateProfileWithLinks() async {
    var profile = ref.read(profileProvider);
    if (profile.twitter != null && profile.twitter!.contains("/")) {
      log(profile.twitter!.split("/").last);
      twitterController.text = profile.twitter!.split("/").last;
    } else {
      twitterController.text = profile.twitter != null ? profile.twitter! : "";
    }
    if (profile.linkedin != null && profile.linkedin!.contains("/")) {
      linkedinController.text = profile.linkedin!.split("/").last;
    } else {
      linkedinController.text =
          profile.linkedin != null ? profile.linkedin! : "";
    }
    if (profile.github != null && profile.github!.contains("/")) {
      githubController.text = profile.github!.split("/").last;
    } else {
      githubController.text = profile.github != null ? profile.github! : "";
    }

    await ref.read(profileProvider.notifier).updateProfile();
  }

  void onSave() async {
    setState(() {
      _isLoading = true;
    });
    var profileProv = ref.read(profileProvider.notifier);
    profileProv.updateSocials(
      linkedin: linkedinController.text.isEmpty ? "" : linkedinController.text,
      github: githubController.text.isEmpty ? "" : githubController.text,
      twitter: twitterController.text.isEmpty ? "" : twitterController.text,
    );
    profileProv.updateInterests(selectedInterests.map((e) => e.name).toList());
    var p = await ref.read(profileProvider.notifier).updateProfile();
    if (p != null) {
      setState(() {
        _isLoading = false;
      });
      widget.onPop!();
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getSocials() {
    var profile = ref.read(profileProvider);
    twitterController.text = profile.twitter != null ? profile.twitter! : "";
    linkedinController.text = profile.linkedin != null ? profile.linkedin! : "";
    githubController.text = profile.github != null ? profile.github! : "";
  }

  getSelectedInterests() {
    var profile = ref.read(profileProvider);
    var profileInterests = profile.interests!.split(',');
    allInterests.forEach((element) {
      if (profileInterests.contains(element.name)) {
        element.selected = true;
        selectedInterests.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Row(
                    children: [
                      IconWrapper(
                        icon: "assets/icons/back.svg",
                        onTap: () {
                          widget.onPop!();
                          Navigator.pop(context);
                        },
                      ),
                      Spacer(),
                      PressEffect(
                        onPressed: _isValid && !_isLoading ? onSave : () {},
                        child: Container(
                          width: 85,
                          height: 40,
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          decoration: BoxDecoration(
                            color: _isValid ? Colors.black : Color(0xff575757),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                      backgroundColor: Colors.transparent,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.22,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.22,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 48),
                  Text(
                    'Socials',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.22,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add complete URL to social profiles',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.22,
                    ),
                  ),
                  SizedBox(height: 32),
                  EditProfileTextField(
                    label: 'Github',
                    prefixText: 'https://github.com/',
                    controller: githubController,
                    disabled: false,
                    enableSuffix: false,
                  ),
                  EditProfileTextField(
                    label: 'LinkedIn',
                    prefixText: 'https://linkedin.com/in/',
                    controller: linkedinController,
                  ),
                  EditProfileTextField(
                    label: 'Twitter ( X )',
                    prefixText: 'https://x.com/',
                    controller: twitterController,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Area of interests',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.22,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pick up to 5 things you like',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff575757),
                      height: 1.22,
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: size.width - 48,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: allInterests
                          .map(
                            (e) => GestureDetector(
                              onTap: selectedInterests.length >= 5 &&
                                      !e.selected
                                  ? null
                                  : () {
                                      setState(() {
                                        var i = allInterests.indexOf(e);
                                        allInterests[i].selected =
                                            !allInterests[i].selected;
                                        selectedInterests = allInterests
                                            .where(
                                                (element) => element.selected)
                                            .toList();
                                        if (selectedInterests.length >= 2 &&
                                            selectedInterests.length <= 5) {
                                          _isValid = true;
                                        } else {
                                          _isValid = false;
                                        }
                                      });
                                    },
                              child: InterestChip(interest: e),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool disabled;
  final bool enableSuffix;
  final VoidCallback? onSuffixTap;
  final String prefixText;
  const EditProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.disabled = false,
    this.enableSuffix = false,
    this.onSuffixTap,
    this.prefixText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xffDEDEDE),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: !disabled,
        scrollPadding: EdgeInsets.zero,
        style: TextStyle(
          fontFamily: 'General Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          height: 1.22,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff575757),
            height: 1.22,
          ),
          border: InputBorder.none,
          prefixText: prefixText,
          suffixIcon: enableSuffix
              ? PressEffect(
                  onPressed: onSuffixTap ?? () {},
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Container(
                      height: 24,
                      width: 84,
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Connect'.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
