import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:url_launcher/url_launcher.dart';

enum SocialIcon { Instagram, Twitter, Linkedin, GitHub }

class SocialLinks extends StatelessWidget {
  final SocialIcon? icon;
  final String? url;
  const SocialLinks({super.key, this.icon, this.url});

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: () => launchUrl(
        Uri.parse(url!),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        height: 32,
        width: 32,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 0.5,
            color: Color(0xffDEDEDE),
          ),
        ),
        child: _getIcon(icon),
      ),
    );
  }

  Widget _getIcon(SocialIcon? icon) {
    switch (icon) {
      case SocialIcon.Instagram:
        return SvgPicture.asset('assets/icons/instagram.svg');
      case SocialIcon.GitHub:
        return SvgPicture.asset('assets/icons/github.svg');
      case SocialIcon.Linkedin:
        return SvgPicture.asset('assets/icons/linkedin.svg');
      case SocialIcon.Twitter:
        return SvgPicture.asset('assets/icons/twitter.svg');
      default:
        return SvgPicture.asset('assets/icons/instagram.svg');
    }
  }
}
