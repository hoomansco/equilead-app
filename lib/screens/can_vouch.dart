import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/crypto.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/models/contact.dart' as c;
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/common/empty_state.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactCanVouch extends StatefulWidget {
  const ContactCanVouch({super.key});

  @override
  State<ContactCanVouch> createState() => _ContactCanVouchState();
}

class _ContactCanVouchState extends State<ContactCanVouch> {
  List<String> phoneNumberHashes = [];
  List<c.Contact> vouchableContacts = [];
  static const platform = MethodChannel('contact_handler');
  static const iosplatform = MethodChannel('app.hub.dev/openSettings');
  @override
  void initState() {
    super.initState();
    getHashedPhoneNumbersFromCloud();
  }

  Future<void> getHashedPhoneNumbersFromCloud() async {
    var resp = await NetworkUtils().httpGet("member/phonehashes/all");
    if (resp!.statusCode == 200) {
      var data = jsonDecode(resp.body);
      phoneNumberHashes = List<String>.from(data);
      getContactsFromPhone();
    }
  }

  Future<void> getContactsFromPhone() async {
    vouchableContacts = [];
    List getcontacts = [];
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
      contacts.forEach((contact) {
        contact["phone"]!.split(',').forEach((phone) {
          var hash = CryptoUtil.hashPhoneNumber(phone);
          if (phoneNumberHashes.contains(hash)) {
            setState(() {
              vouchableContacts.add(c.Contact(
                name: contact["name"],
                phoneNumber: phone,
                initials:
                    contact["name"]!.split(" ").map((e) => e[0]).take(1).join(),
              ));
            });
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: ListView(
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  IconWrapper(
                    icon: "assets/icons/back.svg",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 24),
              Text(
                "Who all can vouch you",
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset("assets/icons/shield-tick-blue.svg"),
                  SizedBox(width: 4),
                  Text(
                    "We don't store your contact information",
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: size.width - 40,
                child: vouchableContacts.isEmpty
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.20),
                        child: EmptyState(
                          text: "You don't have any vouchable contacts",
                          isDark: false,
                        ),
                      )
                    : ListView.separated(
                        itemCount: vouchableContacts.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return DelayedAnimation(
                            delayedAnimation: 200 + (index * 50),
                            aniOffsetX: 0,
                            aniOffsetY: -0.18,
                            aniDuration: 250,
                            child: ListTile(
                              onTap: () {
                                launchUrl(
                                  Uri.parse(
                                      "https://wa.me/${vouchableContacts[index].phoneNumber}${AppConstants.vouchWhatsappText}"),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                vouchableContacts[index].name!,
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: CircleAvatar(
                                child: Text(vouchableContacts[index].initials!),
                                backgroundColor:
                                    AppColors.listColors[index % 6],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 24,
                            color: Color(0xffEBEBEB),
                            thickness: 0.4,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
