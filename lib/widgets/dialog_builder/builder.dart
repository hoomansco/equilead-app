import 'package:flutter/material.dart';
import 'package:equilead/widgets/upgrade/update_popup.dart';

class DialogBuilder {
  DialogBuilder({required this.context});
  final BuildContext context;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  void ShowUpgrade(bool canPop) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: !canPop,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (BuildContext context) {
        return PopScope(
          canPop: !canPop,
          child: Container(
            child: UpdatePopup(canPop: canPop),
          ),
        );
      },
    );
  }

  void HideDialog() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(context);
    }
  }
}
