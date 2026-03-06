// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ITE VR Scheduling';

  @override
  String get agendamientoTitulo => 'ITE VR Scheduling';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuBookings => 'Bookings';

  @override
  String get menuSchedule => 'Schedule';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuLogout => 'Logout';

  @override
  String get labelSede => 'Campus';

  @override
  String get labelFacultad => 'Faculty';

  @override
  String get labelCarrera => 'Degree';

  @override
  String get labelMateria => 'Course';

  @override
  String get labelLaboratorio => 'Classroom';

  @override
  String get labelSoftware => 'Class software';

  @override
  String get labelParalelo => 'Section';

  @override
  String get labelGrupo => 'Group (1 or 2)';

  @override
  String get labelEstudiantes => 'No. of Students (max. 15)';

  @override
  String get labelCapacitacion => 'Requires training?';

  @override
  String get calendarConfirmarTitulo => 'Confirm Booking';

  @override
  String calendarConfirmarMensaje(Object materia, Object paralelo, Object grupo,
      Object estudiantes, Object fecha, Object hora, Object tipo) {
    return 'Subject: $materia\nSection: $paralelo\nGroup: $grupo\nStudents: $estudiantes\nDate: $fecha\nTime: $hora\nType: $tipo';
  }

  @override
  String get btnCancelar => 'Cancel';

  @override
  String get btnConfirmar => 'Confirm';

  @override
  String get confirmar => 'Confirm';

  @override
  String get cancelar => 'Cancel';

  @override
  String get tipoCapacitacion => 'Training';

  @override
  String get tipoPractica => 'Practice';

  @override
  String get footerTexto =>
      'Â© 2025 Universidad CatÃ³lica de Cuenca Â· Support Â· Social Media Â· Contact';

  @override
  String get confirmarAgendamiento => 'Confirm Booking';

  @override
  String get deseaAgendar => 'Do you want to book this slot?';

  @override
  String get ocupado => 'Busy';

  @override
  String get fecha => 'Date';

  @override
  String get hora => 'Time';

  @override
  String get tipo => 'Type';

  @override
  String get semanaDe => 'Week of';

  @override
  String get seleccioneIdioma => 'Select language';

  @override
  String get idiomaEspanol => 'Spanish';

  @override
  String get idiomaIngles => 'English';

  @override
  String get modoClaro => 'Light Mode';

  @override
  String get modoOscuro => 'Dark Mode';

  @override
  String get carruselTitulo1 => 'ITE VR Classroom 1';

  @override
  String get carruselDescripcion1 =>
      'Educational innovation through immersive experiences.';

  @override
  String get carruselTitulo2 => 'Explore in Virtual Reality';

  @override
  String get carruselDescripcion2 =>
      'Complementary classes using cutting-edge technology.';

  @override
  String get carruselTitulo3 => 'Transform Your Learning';

  @override
  String get carruselDescripcion3 =>
      'Visual and motor interaction for all fields.';

  @override
  String get quienesSomos => 'Who Are We';

  @override
  String get descripcionQuienesSomos =>
      'We are the Innovation and Entrepreneurship Unit of Universidad CatÃ³lica de Cuenca, implementing ITE classrooms to revolutionize education.';

  @override
  String get queHacemos => 'What We Do';

  @override
  String get descripcionQueHacemos =>
      'We operate ITE VR classrooms, using virtual reality for complementary classes that offer immersive visual and motor learning experiences.';

  @override
  String get btnAgendar => 'Schedule Now';

  @override
  String get tituloAgendamientoDocente =>
      'Enter the class details to teach in the classroom';

  @override
  String get infoGrupos =>
      'Classrooms are split into two groups to respect the capacity limits and provide the best experience. Choose the group you need to book.';

  @override
  String get infoCapacitacion =>
      'Teachers and students are expected to be trained on how to use the classroom equipment.';

  @override
  String get infoCapacitacionContacto =>
      'If training is required, please contact xxxx to coordinate it.';

  @override
  String get confirmoInfoGrupos =>
      'I confirm I understand why the classroom is split into two groups.';

  @override
  String get confirmoInfoCapacitacion =>
      'I confirm teachers and students are trained or I will contact xxxx if training is needed.';

  @override
  String get mensajeDebeConfirmarCapacitacion =>
      'Please acknowledge the training requirement before selecting a time slot.';

  @override
  String get laboratorioInfoTitulo => 'Classroom details';

  @override
  String laboratorioInfoUbicacion(Object ubicacion) {
    return 'Location: $ubicacion';
  }

  @override
  String laboratorioInfoCapacidad(Object capacidad) {
    return 'Maximum capacity: $capacidad students';
  }

  @override
  String laboratorioInfoMaximo(Object aforo) {
    return 'Recommended occupancy: $aforo';
  }
}
