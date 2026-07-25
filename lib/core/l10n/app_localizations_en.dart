// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Event Hub';

  @override
  String get errorGeneric => 'An unexpected error occurred.';

  @override
  String get errorUnauthorized => 'Unauthorized. Please login again.';

  @override
  String get errorRateLimit => 'Too many requests. Please try again later.';

  @override
  String get errorServer => 'Server error. Please try again later.';
}
