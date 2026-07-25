// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Event Hub';

  @override
  String get errorGeneric => 'Ocurrió un error inesperado.';

  @override
  String get errorUnauthorized =>
      'No autorizado. Por favor, inicie sesión de nuevo.';

  @override
  String get errorRateLimit => 'Demasiadas solicitudes. Inténtelo más tarde.';

  @override
  String get errorServer =>
      'Error en el servidor. Inténtelo de nuevo más tarde.';
}
