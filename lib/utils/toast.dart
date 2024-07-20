import 'package:flutter/material.dart';
import 'package:equilead/widgets/common/toast.dart';

void showAppToast(BuildContext context, String message, ToastType type) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 2),
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: AppToast(
        message: message,
        type: type,
      ),
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
    ),
    snackBarAnimationStyle: AnimationStyle(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOutCirc,
      reverseDuration: Duration(milliseconds: 300),
      reverseCurve: Curves.easeInOutCirc,
    ),
  );
}
