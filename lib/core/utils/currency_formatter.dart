import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatSDG(double amount) {
    final formatter = NumberFormat('#,##0', 'ar_SD');
    return '${formatter.format(amount)} ج.س';
  }

  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'ar_SD');
    return formatter.format(number);
  }
}
