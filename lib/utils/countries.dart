// lib/utils/countries.dart
// قائمة ISO بسيطة + أسماء بالعربي/الإنجليزي + بحث

class Country {
  final String code; // ISO-3166-1 alpha-2
  final String nameEn;
  final String nameAr;
  const Country({
    required this.code,
    required this.nameEn,
    required this.nameAr,
  });
}

const List<Country> kCountries = <Country>[
  Country(code: 'SA', nameEn: 'Saudi Arabia', nameAr: 'السعودية'),
  Country(code: 'AE', nameEn: 'United Arab Emirates', nameAr: 'الإمارات'),
  Country(code: 'KW', nameEn: 'Kuwait', nameAr: 'الكويت'),
  Country(code: 'QA', nameEn: 'Qatar', nameAr: 'قطر'),
  Country(code: 'BH', nameEn: 'Bahrain', nameAr: 'البحرين'),
  Country(code: 'OM', nameEn: 'Oman', nameAr: 'عُمان'),
  Country(code: 'EG', nameEn: 'Egypt', nameAr: 'مصر'),
  Country(code: 'JO', nameEn: 'Jordan', nameAr: 'الأردن'),
  Country(code: 'IQ', nameEn: 'Iraq', nameAr: 'العراق'),
  Country(code: 'LB', nameEn: 'Lebanon', nameAr: 'لبنان'),
  Country(code: 'MA', nameEn: 'Morocco', nameAr: 'المغرب'),
  Country(code: 'DZ', nameEn: 'Algeria', nameAr: 'الجزائر'),
  Country(code: 'TN', nameEn: 'Tunisia', nameAr: 'تونس'),
  Country(code: 'YE', nameEn: 'Yemen', nameAr: 'اليمن'),
  Country(code: 'SY', nameEn: 'Syria', nameAr: 'سوريا'),
  Country(code: 'TR', nameEn: 'Turkey', nameAr: 'تركيا'),
  Country(code: 'US', nameEn: 'United States', nameAr: 'الولايات المتحدة'),
  Country(code: 'GB', nameEn: 'United Kingdom', nameAr: 'المملكة المتحدة'),
  Country(code: 'DE', nameEn: 'Germany', nameAr: 'ألمانيا'),
  Country(code: 'FR', nameEn: 'France', nameAr: 'فرنسا'),
  Country(code: 'IT', nameEn: 'Italy', nameAr: 'إيطاليا'),
  Country(code: 'ES', nameEn: 'Spain', nameAr: 'إسبانيا'),
  Country(code: 'PK', nameEn: 'Pakistan', nameAr: 'باكستان'),
  Country(code: 'IN', nameEn: 'India', nameAr: 'الهند'),
  Country(code: 'PH', nameEn: 'Philippines', nameAr: 'الفلبين'),
  Country(code: 'ID', nameEn: 'Indonesia', nameAr: 'إندونيسيا'),
  Country(code: 'BD', nameEn: 'Bangladesh', nameAr: 'بنغلاديش'),
  Country(code: 'NP', nameEn: 'Nepal', nameAr: 'نيبال'),
  Country(code: 'LK', nameEn: 'Sri Lanka', nameAr: 'سريلانكا'),
  Country(code: 'ET', nameEn: 'Ethiopia', nameAr: 'إثيوبيا'),
];

List<Country> searchCountries(String q) {
  final query = q.trim().toLowerCase();
  if (query.isEmpty) return kCountries;
  return kCountries.where((c) {
    return c.code.toLowerCase().contains(query) ||
        c.nameEn.toLowerCase().contains(query) ||
        c.nameAr.toLowerCase().contains(query);
  }).toList();
}
