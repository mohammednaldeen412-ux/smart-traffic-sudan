/// بيانات ولايات ومحليات جمهورية السودان
/// مع التركيز على النطاق التشغيلي لولاية النيل الأبيض
class SudanLocations {
  SudanLocations._();

  /// ولاية التشغيل الأساسية للنظام
  static const String operationalState = 'النيل الأبيض';

  /// جميع ولايات السودان لترخيص المركبات
  static const List<Map<String, String>> allStates = [
    {'name': 'النيل الأبيض', 'code': 'ن أ', 'symbol': 'WN'},
    {'name': 'الخرطوم', 'code': 'خ', 'symbol': 'KH'},
    {'name': 'الجزيرة', 'code': 'ج', 'symbol': 'GZ'},
    {'name': 'سنار', 'code': 'س', 'symbol': 'SN'},
    {'name': 'البحر الأحمر', 'code': 'ب ح', 'symbol': 'RS'},
    {'name': 'نهر النيل', 'code': 'ن ن', 'symbol': 'NR'},
    {'name': 'الشمالية', 'code': 'ش', 'symbol': 'NO'},
    {'name': 'القضارف', 'code': 'ق', 'symbol': 'GD'},
    {'name': 'كسلا', 'code': 'ك', 'symbol': 'KS'},
    {'name': 'النيل الأزرق', 'code': 'ن ز', 'symbol': 'BN'},
    {'name': 'شمال كردفان', 'code': 'ش ك', 'symbol': 'NK'},
    {'name': 'غرب كردفان', 'code': 'غ ك', 'symbol': 'WK'},
    {'name': 'جنوب كردفان', 'code': 'ج ك', 'symbol': 'SK'},
    {'name': 'شمال دارفور', 'code': 'ش د', 'symbol': 'ND'},
    {'name': 'جنوب دارفور', 'code': 'ج د', 'symbol': 'SD'},
    {'name': 'غرب دارفور', 'code': 'غ د', 'symbol': 'WD'},
    {'name': 'وسط دارفور', 'code': 'و د', 'symbol': 'CD'},
    {'name': 'شرق دارفور', 'code': 'ع د', 'symbol': 'ED'},
  ];

  /// المحليات الرسمية التابعة لولاية النيل الأبيض فقط (نطاق المخالفات والعمليات)
  static const List<String> whiteNileLocalities = [
    'محلية ربك (العاصمة)',
    'محلية كوستي',
    'محلية الدويم',
    'محلية القطينة',
    'محلية تندلتي',
    'محلية أم رمتة',
    'محلية السلام',
    'محلية الجبلين',
  ];

  /// المدن الرئيسية في ولاية النيل الأبيض
  static const List<String> whiteNileCities = [
    'ربك',
    'كوستي',
    'الدويم',
    'القطينة',
    'تندلتي',
    'الجبيلين',
    'النعيم',
    'قلي',
    'الأندرابة',
    'أبو ركبة',
    'الشور',
    'كنانة',
    'عسلاية',
  ];

  /// التحقق مما إذا كانت المحلية تابعة لنطاق النيل الأبيض
  static bool isValidWhiteNileLocality(String locality) {
    return whiteNileLocalities.any(
      (l) => l.contains(locality) || locality.contains(l.replaceAll('محلية ', '')),
    );
  }
}
