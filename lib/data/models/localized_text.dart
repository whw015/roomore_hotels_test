// lib/data/models/localized_text.dart
class LocalizedText {
  final String? ar;
  final String? en;

  const LocalizedText({this.ar, this.en});

  factory LocalizedText.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const LocalizedText();
    return LocalizedText(ar: map['ar'] as String?, en: map['en'] as String?);
  }

  Map<String, dynamic> toMap() => {
    if (ar != null) 'ar': ar,
    if (en != null) 'en': en,
  };

  String resolve(String langCode, {String? fallback}) {
    switch (langCode) {
      case 'ar':
        return ar ?? en ?? fallback ?? '';
      case 'en':
      default:
        return en ?? ar ?? fallback ?? '';
    }
  }
}
