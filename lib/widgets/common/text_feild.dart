import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class OnboardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool? isEnabled;
  final VoidCallback? onTap;
  final bool enableCapitalization;
  final Function(String)? onChanged;
  final String? prefixIcon;
  const OnboardTextField({
    super.key,
    this.onTap,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.isEnabled,
    required this.enableCapitalization,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onTap ?? () {},
      child: SizedBox(
        height: 56,
        child: TextFormField(
          enableInteractiveSelection: false,
          controller: controller,
          keyboardType: keyboardType,
          enabled: isEnabled ?? true,
          textCapitalization: enableCapitalization
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          keyboardAppearance: Brightness.light,
          toolbarOptions: ToolbarOptions(
            copy: false,
            cut: true,
            paste: false,
            selectAll: true,
          ),
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff171717),
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xffbfbfbf),
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: SvgPicture.asset(
                        prefixIcon!,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  )
                : null,
          ),
          onChanged:
              onChanged == null ? (value) {} : (value) => onChanged!(value),
        ),
      ),
    );
  }
}
