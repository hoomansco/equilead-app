import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class CheckboxItem {
  String title;
  String icon;
  bool isSelected;
  int level;

  CheckboxItem({
    required this.title,
    required this.icon,
    this.isSelected = false,
    this.level = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': title,
      'level': level,
    };
  }
}

class CheckboxGroup extends StatelessWidget {
  final List<CheckboxItem> items;
  final Function(int) onChanged;
  const CheckboxGroup({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: items
            .map(
              (e) => PressEffect(
                onPressed: () {
                  var index = items.indexOf(e);
                  onChanged(index);
                },
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
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Image.asset(e.icon),
                      ),
                      SizedBox(width: 8),
                      Text(
                        e.title,
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color:
                              e.isSelected ? Colors.black : Color(0xff575757),
                          height: 1,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 20,
                        width: 20,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                              e.isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                e.isSelected ? Colors.black : Color(0xffBFBFBF),
                            width: 1,
                          ),
                        ),
                        child: e.isSelected
                            ? SvgPicture.asset(
                                "assets/icons/white-tick.svg",
                                width: 8,
                                height: 5.55,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
