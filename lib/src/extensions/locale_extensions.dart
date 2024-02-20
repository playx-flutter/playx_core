import 'dart:ui';

const _rtlLocales = <String>[
  'ar', // Arabic
  'fa', // Farsi
  'he', // Hebrew
  'ps', // Pashto
  'ur', // Urdu
];

/// extensions on the locale
extension LocaleExtensions on Locale {
  /// Check if the language is RTL
  bool get isRTL => _rtlLocales.contains(languageCode.toLowerCase());

  /// return the TextDirection base on the language
  TextDirection get direction =>
      _rtlLocales.contains(languageCode.toLowerCase())
          ? TextDirection.rtl
          : TextDirection.ltr;

  /// Check if the language is Arabic
  bool get isArabic => languageCode.toLowerCase() == 'ar';

  /// Check if the language is English
  bool get isEnglish => languageCode.toLowerCase() == 'en';
}
