// lib/data/models/localized_text.dart
class LocalizedText {
  final String? ar;
  final String? en;

  const LocalizedText({this.ar, this.en});

  // ✅ يتحمّل String أو Map
  factory LocalizedText.fromJson(dynamic json) {
    if (json == null) return const LocalizedText();
    if (json is String) {
      // لو وصل نص فقط، نخزّله في الحقلين كـ fallback:
      return LocalizedText(ar: json, en: json);
    }
    if (json is Map<String, dynamic>) {
      return LocalizedText(
        ar: json['ar'] as String?,
        en: json['en'] as String?,
      );
    }
    return const LocalizedText();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ar != null) map['ar'] = ar;
    if (en != null) map['en'] = en;
    return map;
  }

  // أداة مساعدة
  String resolve(String langCode, {String fallback = ''}) {
    if (langCode.toLowerCase().startsWith('ar')) {
      return (ar?.trim().isNotEmpty == true ? ar! : (en ?? fallback));
    }
    return (en?.trim().isNotEmpty == true ? en! : (ar ?? fallback));
  }
}
