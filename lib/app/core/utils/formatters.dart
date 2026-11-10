import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _inrCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currency,
    decimalDigits: 0,
  );

  static final NumberFormat _inrCurrencyWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currency,
    decimalDigits: 2,
  );

  static String formatPrice(double price, {bool showDecimals = false}) {
    if (showDecimals && price % 1 != 0) {
      return _inrCurrencyWithDecimals.format(price);
    }
    return _inrCurrencyFormat.format(price);
  }

  static String formatCurrency(double price, {bool showDecimals = false}) {
    return formatPrice(price, showDecimals: showDecimals);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
}

