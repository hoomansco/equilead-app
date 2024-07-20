import 'package:flutter/material.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/custom_radio.dart';

class RadioGroup extends StatelessWidget {
  final List<String> items;
  final String? selected;
  final void Function(String?)? onChanged;
  final double? contentWidth;
  const RadioGroup({
    super.key,
    required this.items,
    this.selected,
    this.onChanged,
    this.contentWidth,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (e) => PressEffect(
                  onPressed: () => onChanged!(e),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: e == items.last
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: Colors.black.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: contentWidth ?? size.width * 0.75,
                          child: Text(
                            e,
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: e == selected
                                  ? Colors.black
                                  : Color(0xff757575),
                              height: 1.3,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 3,
                          ),
                        ),
                        RadioButton(
                          value: e,
                          groupValue: selected,
                          onChanged: (value) => onChanged!(value as String),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList()),
    );
  }
}
