import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalise(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalise(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}

String sanitizePhoneNumber(String value) {
  var phone = value.replaceAll(RegExp(r"[^\d]"), '');
  if (phone.length == 10) {
    return '+91${phone}';
  } else if (phone.length == 12) {
    return '+${phone}';
  } else {
    return phone;
  }
}
