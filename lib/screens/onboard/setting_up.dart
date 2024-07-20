import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/main/navigation.dart';
import 'package:equilead/utils/shared_prefs.dart';

class SettingUp extends ConsumerStatefulWidget {
  final int invitedBy;
  const SettingUp({super.key, required this.invitedBy});

  @override
  _SettingUpState createState() => _SettingUpState();
}

class _SettingUpState extends ConsumerState<SettingUp> {
  void setup() {
    var profile = ref.watch(profileProvider);
    var profilePro = ref.watch(profileProvider.notifier);
    if (profile.isOnboard!) {
      profilePro.createProfile(profile).then((value) async {
        print(value.subOrgId);
        print(value.toJson());
        var phone = SharedPrefs().getPhoneNumber();
        await profilePro.updateInviteStatus(
            widget.invitedBy, phone, value.id!, value.name!);
        if (value.uniqueId != null) {
          var userID = SharedPrefs().getUserID();

          SharedPrefs().setMemberID(value.id!.toString());

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(),
            ),
          );
        }
      });
    } else {
      profilePro.updateIsOnboard(true);
      profilePro.updateCompleteProfile().then((value) async {
        var phone = SharedPrefs().getPhoneNumber();
        await profilePro.updateInviteStatus(
            widget.invitedBy, phone, value!.id!, value.name!);
        if (value.uniqueId != null) {
          var userID = SharedPrefs().getUserID();

          SharedPrefs().setMemberID(value.id!.toString());

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(),
            ),
          );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    setup();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacer(),
          Container(
            width: 100,
            height: 100,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xffFFF73A),
              shape: BoxShape.circle,
            ),
            child: Image.asset('assets/images/animated/rocket.png'),
          ),
          SizedBox(height: 24),
          Text(
            'We are setting up your profile...',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
        ],
      ),
    ));
  }
}
