import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/models/partner.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerContactWidget extends StatelessWidget {
  final bool isSpace;
  final PartnerContact partnerContact;
  final String partnerName;

  const PartnerContactWidget({
    super.key,
    required this.partnerContact,
    required this.partnerName,
    required this.isSpace,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.9,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // isSpace
          //     ? CircleAvatar(
          //         minRadius: 20,
          //       )
          //     : SizedBox.shrink(),
          // isSpace ? SizedBox(width: 16) : SizedBox.shrink(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partnerContact.name!,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.22,
                ),
              ),
              SizedBox(height: 2),
              SizedBox(
                width: size.width * 0.4,
                child: Text(
                  '${partnerContact.title}${partnerName != '' ? ',' : ''} $partnerName',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff575757),
                    height: 1.22,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          Spacer(),
          PressEffect(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (isSpace) {
                launchUrl(
                  Uri.parse('https://wa.me/${partnerContact.phone!}'),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                if (partnerContact.email != null) {
                  launchUrl(Uri.parse('mailto:${partnerContact.email}'));
                } else {
                  launchUrl(
                    Uri.parse('https://wa.me/${partnerContact.phone!}'),
                    mode: LaunchMode.externalApplication,
                  );
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CONTACT',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/arrow-top-right.svg",
                  height: 18,
                  width: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
