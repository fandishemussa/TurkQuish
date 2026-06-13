import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String compact(DateTime value) {
    return DateFormat.yMMMd().add_Hm().format(value.toLocal());
  }
}
