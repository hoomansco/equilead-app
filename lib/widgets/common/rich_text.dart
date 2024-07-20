import 'package:flutter/material.dart';

class HeaderRichText extends StatelessWidget {
  final String text1;
  final String text2;
  const HeaderRichText({
    super.key,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text1,
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff2E2E2E),
              height: 0.7,
              letterSpacing: -0.4,
            ),
          ),
          TextSpan(
            text: ' $text2',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xffA3A3A3),
            ),
          ),
        ],
      ),
    );
  }
}
