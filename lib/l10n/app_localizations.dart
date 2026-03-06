import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ITE VR Scheduling'**
  String get appTitle;

  /// No description provided for @agendamientoTitulo.
  ///
  /// In en, this message translates to:
  /// **'ITE VR Scheduling'**
  String get agendamientoTitulo;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @menuBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get menuBookings;

  /// No description provided for @menuSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get menuSchedule;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// No description provided for @labelSede.
  ///
  /// In en, this message translates to:
  /// **'Campus'**
  String get labelSede;

  /// No description provided for @labelFacultad.
  ///
  /// In en, this message translates to:
  /// **'Faculty'**
  String get labelFacultad;

  /// No description provided for @labelCarrera.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get labelCarrera;

  /// No description provided for @labelMateria.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get labelMateria;

  /// No description provided for @labelLaboratorio.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get labelLaboratorio;

  /// No description provided for @labelSoftware.
  ///
  /// In en, this message translates to:
  /// **'Class software'**
  String get labelSoftware;

  /// No description provided for @labelParalelo.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get labelParalelo;

  /// No description provided for @labelGrupo.
  ///
  /// In en, this message translates to:
  /// **'Group (1 or 2)'**
  String get labelGrupo;

  /// No description provided for @labelEstudiantes.
  ///
  /// In en, this message translates to:
  /// **'No. of Students (max. 15)'**
  String get labelEstudiantes;

  /// No description provided for @labelCapacitacion.
  ///
  /// In en, this message translates to:
  /// **'Requires training?'**
  String get labelCapacitacion;

  /// No description provided for @calendarConfirmarTitulo.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get calendarConfirmarTitulo;

  /// Message to confirm booking with full info
  ///
  /// In en, this message translates to:
  /// **'Subject: {materia}\nSection: {paralelo}\nGroup: {grupo}\nStudents: {estudiantes}\nDate: {fecha}\nTime: {hora}\nType: {tipo}'**
  String calendarConfirmarMensaje(Object materia, Object paralelo, Object grupo,
      Object estudiantes, Object fecha, Object hora, Object tipo);

  /// No description provided for @btnCancelar.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancelar;

  /// No description provided for @btnConfirmar.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirmar;

  /// No description provided for @confirmar.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmar;

  /// No description provided for @cancelar.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelar;

  /// No description provided for @tipoCapacitacion.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get tipoCapacitacion;

  /// No description provided for @tipoPractica.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get tipoPractica;

  /// No description provided for @footerTexto.
  ///
  /// In en, this message translates to:
  /// **'Â© 2025 Universidad CatÃ³lica de Cuenca Â· Support Â· Social Media Â· Contact'**
  String get footerTexto;

  /// No description provided for @confirmarAgendamiento.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmarAgendamiento;

  /// No description provided for @deseaAgendar.
  ///
  /// In en, this message translates to:
  /// **'Do you want to book this slot?'**
  String get deseaAgendar;

  /// No description provided for @ocupado.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get ocupado;

  /// No description provided for @fecha.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fecha;

  /// No description provided for @hora.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get hora;

  /// No description provided for @tipo.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get tipo;

  /// No description provided for @semanaDe.
  ///
  /// In en, this message translates to:
  /// **'Week of'**
  String get semanaDe;

  /// No description provided for @seleccioneIdioma.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get seleccioneIdioma;

  /// No description provided for @idiomaEspanol.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get idiomaEspanol;

  /// No description provided for @idiomaIngles.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get idiomaIngles;

  /// No description provided for @modoClaro.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get modoClaro;

  /// No description provided for @modoOscuro.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get modoOscuro;

  /// No description provided for @carruselTitulo1.
  ///
  /// In en, this message translates to:
  /// **'ITE VR Classroom 1'**
  String get carruselTitulo1;

  /// No description provided for @carruselDescripcion1.
  ///
  /// In en, this message translates to:
  /// **'Educational innovation through immersive experiences.'**
  String get carruselDescripcion1;

  /// No description provided for @carruselTitulo2.
  ///
  /// In en, this message translates to:
  /// **'Explore in Virtual Reality'**
  String get carruselTitulo2;

  /// No description provided for @carruselDescripcion2.
  ///
  /// In en, this message translates to:
  /// **'Complementary classes using cutting-edge technology.'**
  String get carruselDescripcion2;

  /// No description provided for @carruselTitulo3.
  ///
  /// In en, this message translates to:
  /// **'Transform Your Learning'**
  String get carruselTitulo3;

  /// No description provided for @carruselDescripcion3.
  ///
  /// In en, this message translates to:
  /// **'Visual and motor interaction for all fields.'**
  String get carruselDescripcion3;

  /// No description provided for @quienesSomos.
  ///
  /// In en, this message translates to:
  /// **'Who Are We'**
  String get quienesSomos;

  /// No description provided for @descripcionQuienesSomos.
  ///
  /// In en, this message translates to:
  /// **'We are the Innovation and Entrepreneurship Unit of Universidad CatÃ³lica de Cuenca, implementing ITE classrooms to revolutionize education.'**
  String get descripcionQuienesSomos;

  /// No description provided for @queHacemos.
  ///
  /// In en, this message translates to:
  /// **'What We Do'**
  String get queHacemos;

  /// No description provided for @descripcionQueHacemos.
  ///
  /// In en, this message translates to:
  /// **'We operate ITE VR classrooms, using virtual reality for complementary classes that offer immersive visual and motor learning experiences.'**
  String get descripcionQueHacemos;

  /// No description provided for @btnAgendar.
  ///
  /// In en, this message translates to:
  /// **'Schedule Now'**
  String get btnAgendar;

  /// No description provided for @tituloAgendamientoDocente.
  ///
  /// In en, this message translates to:
  /// **'Enter the class details to teach in the classroom'**
  String get tituloAgendamientoDocente;

  /// No description provided for @infoGrupos.
  ///
  /// In en, this message translates to:
  /// **'Classrooms are split into two groups to respect the capacity limits and provide the best experience. Choose the group you need to book.'**
  String get infoGrupos;

  /// No description provided for @infoCapacitacion.
  ///
  /// In en, this message translates to:
  /// **'Teachers and students are expected to be trained on how to use the classroom equipment.'**
  String get infoCapacitacion;

  /// No description provided for @infoCapacitacionContacto.
  ///
  /// In en, this message translates to:
  /// **'If training is required, please contact xxxx to coordinate it.'**
  String get infoCapacitacionContacto;

  /// No description provided for @confirmoInfoGrupos.
  ///
  /// In en, this message translates to:
  /// **'I confirm I understand why the classroom is split into two groups.'**
  String get confirmoInfoGrupos;

  /// No description provided for @confirmoInfoCapacitacion.
  ///
  /// In en, this message translates to:
  /// **'I confirm teachers and students are trained or I will contact xxxx if training is needed.'**
  String get confirmoInfoCapacitacion;

  /// No description provided for @mensajeDebeConfirmarCapacitacion.
  ///
  /// In en, this message translates to:
  /// **'Please acknowledge the training requirement before selecting a time slot.'**
  String get mensajeDebeConfirmarCapacitacion;

  /// Header for classroom details
  ///
  /// In en, this message translates to:
  /// **'Classroom details'**
  String get laboratorioInfoTitulo;

  /// No description provided for @laboratorioInfoUbicacion.
  ///
  /// In en, this message translates to:
  /// **'Location: {ubicacion}'**
  String laboratorioInfoUbicacion(Object ubicacion);

  /// No description provided for @laboratorioInfoCapacidad.
  ///
  /// In en, this message translates to:
  /// **'Maximum capacity: {capacidad} students'**
  String laboratorioInfoCapacidad(Object capacidad);

  /// No description provided for @laboratorioInfoMaximo.
  ///
  /// In en, this message translates to:
  /// **'Recommended occupancy: {aforo}'**
  String laboratorioInfoMaximo(Object aforo);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
