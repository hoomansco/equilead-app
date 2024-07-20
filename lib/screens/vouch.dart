import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/vouch.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/contacts_vouch.dart';
import 'package:equilead/screens/external_profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/action_sheet.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';

class VouchPage extends ConsumerStatefulWidget {
  const VouchPage({super.key});

  @override
  _VouchPageState createState() => _VouchPageState();
}

class _VouchPageState extends ConsumerState<VouchPage> {
  List<Vouch> vouches = [];
  bool _isLoading = true;
  int inviteCount = 0;
  int maxInviteCount = AppConstants.maxInviteLimit;
  bool canVouch = false;
  String selectedPhoneNumber = "";
  static const platform = MethodChannel('contact_handler');
  static const iosplatform = MethodChannel('app.hub.dev/openSettings');

  Future<void> _contactSelection() async {
    selectedPhoneNumber = "";
    HapticFeedback.lightImpact();
    List<dynamic> getcontacts = [];
    try {
      if (Platform.isAndroid) {
        var permission =
            await platform.invokeMethod("requestContactsPermission");
        if (permission == true) {
          getcontacts =
              List.castFrom(await platform.invokeMethod("getContacts"));
        }
      } else {
        getcontacts =
            List.castFrom(await iosplatform.invokeMethod("getContacts"));
      }
      var contacts = getcontacts.map((contact) {
        return Map<String, String>.from(contact);
      }).toList();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ContactsVouch(
              contacts: contacts,
              onSelectedContact: (contact, name) async {
                var lables = List.generate(contacts.length, (i) => "mobile");
                await showContactSelectionModal(
                  contact,
                  lables,
                  name,
                );
              })));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onVouch(String name, String phone) async {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    var profile = ref.read(profileProvider);
    var vouch = Vouch(
      inviterMembershipId: profile.id,
      inviteePhoneNumber: phone,
      inviteeName: name,
      status: 'invited',
    );

    // check if anyone already vouched this number
    var resp = await NetworkUtils().httpGet(
      'member/invite/${vouch.inviteePhoneNumber}',
    );

    if (resp?.statusCode == 200) {
      await showErrorModal(name);
    } else {
      var resp = await NetworkUtils().httpPost(
        'member/invite/create',
        vouch.toJson(),
      );
      if (resp?.statusCode == 201) {
        await showSuccessModal();
        _getVouches();
      }
    }
  }

  Future<void> _getVouches() async {
    var profile = ref.read(profileProvider);
    var phoneNumber = SharedPrefs().getPhoneNumber();
    var resp = await NetworkUtils().httpGet('member/invite/m/${profile.id}');
    if (resp?.statusCode == 200) {
      if (json.decode(resp!.body)["status"]) {
        Iterable l = json.decode(resp.body)["data"];
        List<Vouch> vouches =
            List<Vouch>.from(l.map((model) => Vouch.fromJson(model))).toList();
        setState(() {
          inviteCount = vouches.length;
          this.vouches = vouches;
          _isLoading = false;
          if (inviteCount < maxInviteCount ||
              AppConstants.vouchPhoneNumbers.contains(phoneNumber)) {
            canVouch = true;
          } else {
            canVouch = false;
          }
        });
      } else {
        canVouch = true;
        setState(() {
          this.vouches = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _getVouches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 4, 20, 32),
            color: AppColors.secondaryGray1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                IconWrapper(
                  icon: "assets/icons/back.svg",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 88,
                  child: Image.asset('assets/images/animated/clap.png'),
                ),
                SizedBox(height: 24),
                Text(
                  'Vouch your friends',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text:
                        "Invite your friends and let's grow our community together! You can refer up to ",
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      color: Color(0xff575757),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: '10 friends',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                PressEffect(
                  onPressed: () => canVouch ? _contactSelection() : null,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: canVouch ? Colors.black : Color(0xff575757),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Vouch',
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(width: 4),
                        SvgPicture.asset('assets/icons/arrow-right-w.svg')
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                Text(
                  'Vouched by you',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.32,
                  ),
                ),
                SizedBox(height: 24),
                _isLoading
                    ? SizedBox(
                        width: size.width,
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : vouches.isEmpty
                        ? Container(
                            width: size.width,
                            padding: EdgeInsets.symmetric(vertical: 24),
                            alignment: Alignment.center,
                            child: Text(
                              'No vouches yet',
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff575757),
                                height: 1.5,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: size.width,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: vouches.length,
                              itemBuilder: (context, index) {
                                return DelayedAnimation(
                                  delayedAnimation: 100 + (index * 50),
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 300,
                                  child: PressEffect(
                                    onPressed:
                                        vouches[index].status == 'accepted'
                                            ? () {
                                                HapticFeedback.lightImpact();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ExternalProfile(
                                                      uniqueId: vouches[index]
                                                          .inviteeUniqueId!,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : () {},
                                    child: VouchedMember(
                                      avatar:
                                          vouches[index].status == 'accepted'
                                              ? vouches[index].inviteeAvatar!
                                              : avatars[index % 6],
                                      title: vouches[index].inviteeName!,
                                      subtitle:
                                          vouches[index].inviteePhoneNumber!,
                                      isAccepted:
                                          vouches[index].status == 'accepted',
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.secondaryGray1,
                                );
                              },
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showContactSelectionModal(
      List<String> phoneNumbers, List<String> label, String name) async {
    Size size = MediaQuery.of(context).size;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phoneNumbers.length == 1
                      ? 'Confirm the number for vouch'
                      : 'Which one should you vouch for?',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.42,
                  ),
                ),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: "$name",
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff2E2E2E),
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: " has following contact number(s)",
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff2E2E2E),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: phoneNumbers.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return VouchContacts(
                        isSelected: selectedPhoneNumber == phoneNumbers[index],
                        number: phoneNumbers[index],
                        label: label[index],
                        onPressed: () {
                          setModalState(() {
                            selectedPhoneNumber = phoneNumbers[index];
                          });
                        },
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                  ),
                ),
                SizedBox(height: 32),
                PressEffect(
                  onPressed: () => selectedPhoneNumber.isNotEmpty
                      ? _onVouch(name, selectedPhoneNumber)
                      : null,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPhoneNumber.isNotEmpty
                          ? Colors.black
                          : Color(0xffA3A3A3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Vouch',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> showSuccessModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: CommonActionSheet(
          action: AppAction.Success,
          text: 'Vouched successfully',
        ),
      ),
    );
  }

  Future<void> showErrorModal(String name) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: CommonActionSheet(
          action: AppAction.Error,
          text: '$name is already vouched by someone.',
        ),
      ),
    );
  }
}

class VouchContacts extends StatelessWidget {
  const VouchContacts({
    super.key,
    this.isSelected = false,
    this.number = "",
    this.label = "",
    required this.onPressed,
  });

  final bool isSelected;
  final String number;
  final String label;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Color(0xffEBEBEB),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryGray1,
              ),
              child: SvgPicture.asset("assets/icons/phone.svg"),
            ),
            SizedBox(width: 24),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff575757),
                    height: 1.2,
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              height: 16,
              width: 16,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Color(0xff3CD377) : Colors.white,
                border: Border.all(
                  color: isSelected ? Color(0xff3CD377) : Color(0xffBFBFBF),
                  width: 0.6,
                ),
              ),
              child: SvgPicture.asset(
                "assets/icons/white-tick.svg",
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class VouchedMember extends StatelessWidget {
  const VouchedMember({
    super.key,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.isAccepted,
  });

  final String avatar;
  final String title;
  final String subtitle;
  final bool isAccepted;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                isAccepted ? Image.network(avatar).image : AssetImage(avatar),
          ),
          SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAccepted ? Color(0xffECFDF3) : AppColors.secondaryGray1,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              isAccepted ? 'ACCEPTED' : 'VOUCHED',
              style: TextStyle(
                fontFamily: 'General Sans',
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
