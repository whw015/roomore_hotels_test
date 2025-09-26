import 'package:flutter/material.dart';

SnackBar _buildSnack(String text, {bool error = false}) {
  return SnackBar(
    content: Text(text),
    backgroundColor: error ? Colors.red.shade700 : null,
    behavior: SnackBarBehavior.floating,
  );
}

void showSuccessSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(_buildSnack(text));
}

void showErrorSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(_buildSnack(text, error: true));
}

