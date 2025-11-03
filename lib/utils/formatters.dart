import 'package:intl/intl.dart';


class Formatters {
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    final format = DateFormat('dd MMM yyyy', 'id_ID');
    return format.format(date);
  }
}
