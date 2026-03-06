// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Agendamiento ITE VR';

  @override
  String get agendamientoTitulo => 'Agendamiento ITE VR';

  @override
  String get menuProfile => 'Perfil';

  @override
  String get menuBookings => 'Reservas';

  @override
  String get menuSchedule => 'Agendar';

  @override
  String get menuSettings => 'Configuraciones';

  @override
  String get menuLogout => 'Cerrar sesión';

  @override
  String get labelSede => 'Sede';

  @override
  String get labelFacultad => 'Facultad';

  @override
  String get labelCarrera => 'Carrera';

  @override
  String get labelMateria => 'Asignatura';

  @override
  String get labelLaboratorio => 'Aula';

  @override
  String get labelSoftware => 'Software para la clase';

  @override
  String get labelParalelo => 'Paralelo';

  @override
  String get labelGrupo => 'Grupo (1 o 2)';

  @override
  String get labelEstudiantes => 'N.º de estudiantes (máx. 15)';

  @override
  String get labelCapacitacion => '¿Requiere capacitación?';

  @override
  String get calendarConfirmarTitulo => 'Confirmar Agendamiento';

  @override
  String calendarConfirmarMensaje(Object materia, Object paralelo, Object grupo,
      Object estudiantes, Object fecha, Object hora, Object tipo) {
    return 'Materia: $materia\nParalelo: $paralelo\nGrupo: $grupo\nEstudiantes: $estudiantes\nFecha: $fecha\nHora: $hora\nTipo: $tipo';
  }

  @override
  String get btnCancelar => 'Cancelar';

  @override
  String get btnConfirmar => 'Confirmar';

  @override
  String get confirmar => 'Confirmar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get tipoCapacitacion => 'Capacitación';

  @override
  String get tipoPractica => 'Práctica';

  @override
  String get footerTexto =>
      'Â© 2025 Universidad CatÃ³lica de Cuenca Â· Soporte Â· Redes Sociales Â· Contacto';

  @override
  String get confirmarAgendamiento => 'Confirmar Agendamiento';

  @override
  String get deseaAgendar => 'Â¿Deseas agendar esta hora?';

  @override
  String get ocupado => 'Ocupado';

  @override
  String get fecha => 'Fecha';

  @override
  String get hora => 'Hora';

  @override
  String get tipo => 'Tipo';

  @override
  String get semanaDe => 'Semana de';

  @override
  String get seleccioneIdioma => 'Seleccionar idioma';

  @override
  String get idiomaEspanol => 'Español';

  @override
  String get idiomaIngles => 'Inglés';

  @override
  String get modoClaro => 'Modo claro';

  @override
  String get modoOscuro => 'Modo oscuro';

  @override
  String get carruselTitulo1 => 'Aula ITE VR 1';

  @override
  String get carruselDescripcion1 =>
      'InnovaciÃ³n educativa con experiencias inmersivas.';

  @override
  String get carruselTitulo2 => 'Explora en Realidad Virtual';

  @override
  String get carruselDescripcion2 =>
      'Clases complementarias con tecnologÃ­a de punta.';

  @override
  String get carruselTitulo3 => 'Transforma tu aprendizaje';

  @override
  String get carruselDescripcion3 =>
      'InteracciÃ³n visual y motriz para todas las carreras.';

  @override
  String get quienesSomos => 'Â¿QuiÃ©nes Somos?';

  @override
  String get descripcionQuienesSomos =>
      'Somos la Jefatura de InnovaciÃ³n y Emprendimiento de la Universidad CatÃ³lica de Cuenca, implementando aulas ITE para revolucionar la educaciÃ³n.';

  @override
  String get queHacemos => 'Â¿QuÃ© Hacemos?';

  @override
  String get descripcionQueHacemos =>
      'Operamos aulas ITE VR, usando realidad virtual para clases complementarias que ofrecen experiencias de aprendizaje inmersivas visuales y motrices.';

  @override
  String get btnAgendar => 'Agendar Ahora';

  @override
  String get tituloAgendamientoDocente =>
      'Ingrese los datos de la clase a dictar en el Aula';

  @override
  String get infoGrupos =>
      'Las aulas se dividen en dos grupos para respetar el aforo máximo y mejorar la experiencia. Selecciona el grupo que deseas agendar.';

  @override
  String get infoCapacitacion =>
      'Para usar el aula se prevé que el docente y los estudiantes estén capacitados en el uso del equipo.';

  @override
  String get infoCapacitacionContacto =>
      'Si requieren capacitación, por favor contactarse con xxxx para coordinarla.';

  @override
  String get confirmoInfoGrupos =>
      'Confirmo que comprendí por qué el aula se divide en dos grupos.';

  @override
  String get confirmoInfoCapacitacion =>
      'Confirmo que docentes y estudiantes están capacitados o contactaré a xxxx para solicitarlo.';

  @override
  String get mensajeDebeConfirmarCapacitacion =>
      'Debes confirmar la capacitación antes de seleccionar un horario.';

  @override
  String get laboratorioInfoTitulo => 'Detalles del aula';

  @override
  String laboratorioInfoUbicacion(Object ubicacion) {
    return 'Ubicación: $ubicacion';
  }

  @override
  String laboratorioInfoCapacidad(Object capacidad) {
    return 'Capacidad máxima: $capacidad estudiantes';
  }

  @override
  String laboratorioInfoMaximo(Object aforo) {
    return 'Aforo recomendado: $aforo';
  }
}
