import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

SnackBar _buildSnack(BuildContext context, String text, {bool error = false}) {
  final bg = error ? Colors.red.shade100 : Colors.green.shade100;
  const fg = Colors.black87;
  return SnackBar(
    content: Text(text, style: const TextStyle(color: fg)),
    backgroundColor: bg,
    behavior: SnackBarBehavior.floating,
  );
}

void showSuccessSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(_buildSnack(context, text));
}

void showErrorSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(_buildSnack(context, text, error: true));
}

// Returns a localized, user-friendly error message for common cases.
String friendlyErrorMessage(Object error, [BuildContext? context]) {
  final lang = context?.locale.languageCode ?? 'en';
  final isAr = lang.toLowerCase().startsWith('ar');
  final s = error.toString();
  // Network/connection issues
  if (s.contains('SocketException') ||
      s.toLowerCase().contains('failed host lookup') ||
      s.toLowerCase().contains('network')) {
    return isAr
        ? 'لا يوجد اتصال بالإنترنت. يرجى التحقق والمحاولة مجددًا.'
        : 'No internet connection. Check your network and try again.';
  }
  // Guests loading
  if (s.contains('Failed to load guests')) {
    if (s.contains('(500)')) {
      return isAr
          ? 'حدث خطأ من الخادم أثناء تحميل النزلاء (500).'
          : 'Server error while loading guests (500).';
    }
    return isAr
        ? 'تعذر تحميل قائمة النزلاء. حاول لاحقًا.'
        : 'Could not load guests. Please try again.';
  }
  if (s.toLowerCase().contains('guest not found')) {
    return isAr
        ? 'لم يتم العثور على نزيل بالبيانات المدخلة.'
        : 'Guest not found for the entered data.';
  }
  // Check-in/out failures
  if (s.toLowerCase().contains('check in guest') || s.toLowerCase().contains('check out guest')) {
    if (s.contains('(404)')) {
      return isAr
          ? 'تعذر تنفيذ العملية (المسار غير موجود 404).'
          : 'Operation failed (endpoint not found 404).';
    }
    return isAr
        ? 'تعذر تنفيذ العملية، يرجى المحاولة لاحقًا.'
        : 'Operation failed, please try again later.';
  }

  // Generic fallback
  return isAr
      ? 'حدث خطأ غير متوقع. حاول مرة أخرى.'
      : 'An unexpected error occurred. Please try again.';
}
