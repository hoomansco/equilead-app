import 'package:flutter/material.dart';

enum ToastType { error, success, info }

class AppToast extends StatelessWidget {
  final String message;
  final ToastType type;

  const AppToast({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: type == ToastType.error
              ? Color(0xffFF0059).withOpacity(0.02)
              : Color(0xffF3F2F8),
          border: Border.all(
            color: Color(0xffF3F2F8),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xff090B21).withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: type == ToastType.error
                    ? Color(0xffFF0059).withOpacity(0.06)
                    : Color(0xffF3F2F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                type == ToastType.error
                    ? Icons.error_outline
                    : Icons.info_outline,
                color: type == ToastType.error
                    ? Color(0xffFF0059)
                    : Color(0xff6361D9),
                size: 12,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
