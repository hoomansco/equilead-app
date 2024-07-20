import 'package:flutter/material.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class RadioButton extends StatelessWidget {
  final String value;
  final String? groupValue;
  final void Function(String?)? onChanged;
  const RadioButton({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: () {
        if (value != groupValue) onChanged!(value);
      },
      child: Container(
        height: 20,
        width: 20,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value == groupValue ? Colors.black : Colors.white,
          border: Border.all(
            color: value == groupValue ? Colors.black : Color(0xffBFBFBF),
            width: 1,
          ),
        ),
        child: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value == groupValue ? Colors.white : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
