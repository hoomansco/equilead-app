import 'package:flutter/material.dart';
import 'package:equilead/theme/colors.dart';

class ChipWidget extends StatelessWidget {
  final List<String> chips;
  final bool blackBorder;
  final bool isExternal;

  const ChipWidget({
    super.key,
    required this.chips,
    required this.blackBorder,
    required this.isExternal,
  });

  // @override
  // Widget build(BuildContext context) {
  //   Size size = MediaQuery.of(context).size;
  //   return SizedBox(
  //     width: size.width * 0.85,
  //     child: Wrap(
  //       spacing: 8,
  //       runSpacing: 8,
  //       children: chips
  //           .map((e) => EventChip(
  //                 text: e,
  //                 blackBorder: blackBorder,
  //               ))
  //           .toList(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.85,
      height: 21,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: isExternal ? (chips.length + 1) : chips.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return EventChip(
            isExternal: (index == 0 && isExternal),
            text: (index == 0 && isExternal)
                ? 'EXTERNAL'
                : chips[isExternal ? (index - 1) : index],
            blackBorder: blackBorder,
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 12),
      ),
    );
  }
}

class EventChip extends StatelessWidget {
  final String text;
  final bool blackBorder;
  final bool isExternal;
  const EventChip({
    super.key,
    required this.text,
    required this.blackBorder,
    required this.isExternal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isExternal
            ? Colors.black
            : AppColors.secondaryGray1.withOpacity(0.9),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'General Sans',
          fontSize: 12,
          fontWeight: isExternal ? FontWeight.w600 : FontWeight.w400,
          color: !isExternal ? Colors.black : Color(0xffFFF73A),
          height: 1.42,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
