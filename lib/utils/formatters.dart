import 'package:intl/intl.dart';

String _localeTag(String? locale) => locale ?? 'tr_TR';

String formatMoney(double amount, {String? locale}) =>
    NumberFormat.currency(
      locale: _localeTag(locale),
      symbol: '₺',
      decimalDigits: 2,
    ).format(amount);

String formatDate(DateTime date, {String? locale}) =>
    DateFormat('d MMM yyyy', _localeTag(locale)).format(date);

String formatMonth(DateTime date, {String? locale}) =>
    DateFormat('MMMM yyyy', _localeTag(locale)).format(date);

String formatShortDate(DateTime date, {String? locale}) =>
    DateFormat('d MMM', _localeTag(locale)).format(date);

String localeTagFromCode(String languageCode) {
  switch (languageCode) {
    case 'en':
      return 'en_US';
    default:
      return 'tr_TR';
  }
}
