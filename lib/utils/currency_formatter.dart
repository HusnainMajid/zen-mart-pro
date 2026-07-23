import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    // Using en_PK locale and 'Rs. ' symbol, with 0 decimal places
    return NumberFormat.currency(
      locale: 'en_PK',
      symbol: 'Rs. ',
      decimalDigits: 0,
    ).format(amount);
  }
}

