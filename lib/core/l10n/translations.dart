/// Traducciones completas para la aplicación ITE VR
/// Basado en el rediseño de Figma 2025
class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'es': {
      // ============== NAVEGACIÓN Y COMÚN ==============
      'login': 'Iniciar Sesión',
      'logout': 'Cerrar Sesión',
      'welcome': 'Bienvenido a ITE VR',
      'continue_btn': 'Continuar',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'save': 'Guardar',
      'back': 'Volver',
      'next': 'Siguiente',
      'menu': 'Menú',
      'close': 'Cerrar',
      'edit': 'Editar',
      'delete': 'Eliminar',
      'add': 'Agregar',
      'search': 'Buscar',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      
      // ============== LANDING PAGE ==============
      'who_we_are': '¿Quiénes Somos?',
      'what_we_do': '¿Qué Hacemos?',
      'schedule_now': 'Agendar Ahora',
      'who_we_are_text': 'Somos el aula de Realidad Virtual del Instituto de Investigación y Emprendimiento (ITE) de la Universidad Católica de Cuenca. Nos dedicamos a proporcionar experiencias inmersivas de aprendizaje utilizando tecnología de vanguardia.',
      'what_we_do_text': 'Ofrecemos acceso a nuestras aulas de VR para docentes y estudiantes. Facilitamos sesiones educativas inmersivas en diversas áreas del conocimiento, desde anatomía hasta arquitectura, utilizando equipos de última generación.',
      
      // Features
      'easy_booking': 'Reserva Fácil',
      'easy_booking_desc': 'Sistema de agendamiento en línea disponible 24/7',
      'training_included': 'Capacitación Incluida',
      'training_included_desc': 'Entrenamiento previo para docentes en el uso de VR',
      'advanced_tech': 'Tecnología Avanzada',
      'advanced_tech_desc': 'Equipos Meta Quest 3 y software educativo especializado',
      
      // Stats
      'laboratories': 'Aulas',
      'vr_equipment': 'Equipos VR',
      'sessions_per_month': 'Sesiones/mes',
      
      // CTA
      'ready_to_innovate': '¿Listo para innovar en tu clase?',
      'cta_description': 'Agenda tu aula de VR y lleva la educación al siguiente nivel',
      'start_now': 'Comenzar Ahora',
      
      // Footer
      'quick_links': 'Enlaces Rápidos',
      'about_us': 'Sobre Nosotros',
      'services': 'Servicios',
      'contact': 'Contacto',
      'follow_us': 'Síguenos',
      'all_rights_reserved': 'Todos los derechos reservados',
      
      // VR Equipment
      'our_vr_equipment': 'Nuestro Equipamiento VR',
      'vr_equipment_desc': 'Contamos con la última tecnología en realidad virtual para experiencias educativas inmersivas',
      'equipment_availability': 'Disponibilidad de Equipos',
      'total_devices': 'Total: 15 dispositivos de realidad virtual disponibles para reserva',
      
      // ============== LOGIN PAGE ==============
      'login_title': 'Iniciar Sesión',
      'login_subtitle': 'Accede con tus credenciales universitarias',
      'secure_access': 'Acceso Seguro',
      'secure_access_desc': 'Autenticación con credenciales universitarias',
      'real_time_booking': 'Reservas en Tiempo Real',
      'real_time_booking_desc': 'Visualiza disponibilidad y agenda instantáneamente',
      'fast_process': 'Proceso Rápido',
      'fast_process_desc': 'Completa tu reserva en menos de 3 minutos',
      'demo_mode': 'Demo Mode',
      'demo_mode_text': 'En producción, aquí se integrará el sistema de autenticación institucional (SSO).',
      'institutional_email': 'Correo Institucional',
      'password': 'Contraseña',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'need_help': '¿Necesitas ayuda?',
      'contact_support': 'Contacta soporte',
      'test_users': 'Usuarios de prueba:',
      'teacher_user': 'Docente',
      'admin_user': 'Admin',
      'invalid_credentials': 'Usuario o contraseña incorrectos',
      'welcome_scheduling_system': 'Bienvenido al Sistema de Agendamiento',
      
      // ============== TEACHER SCHEDULING ==============
      'enter_class_data': 'Ingrese los datos de la clase',
      'complete_form_to_book': 'Complete el formulario para reservar',
      'training_required': 'Confirmo que entiendo que se requiere capacitación previa para usar el aula de VR',
      'training_mandatory': 'La capacitación es obligatoria para usar los equipos',
      'teacher_info': 'Información del Docente',
      'teacher_name': 'Nombre del Docente',
      'enter_full_name': 'Ingrese su nombre completo',
      'select_lab': 'Seleccionar Aula',
      'location': 'Ubicación',
      'capacity': 'Capacidad',
      'max_capacity': 'Capacidad máxima',
      'students': 'estudiantes',
      'class_details': 'Datos de la Clase',
      'subject': 'Asignatura',
      'subject_placeholder': 'Ej: Anatomía Humana',
      'career': 'Carrera',
      'parallel': 'Paralelo',
      'cycle': 'Ciclo',
      'group': 'Grupo',
      'num_students': 'Número de Estudiantes',
      'group_explanation': 'Para aulas con más de 15 estudiantes, debe dividir en 2 grupos',
      'select_schedule': 'Seleccionar Horario',
      'week': 'Semana de',
      'available': 'Disponible',
      'selected': 'Seleccionado',
      'occupied': 'Ocupado',
      'confirm_booking': 'Confirmar Reserva',
      'select_option': 'Seleccione...',
      'confirm_teacher': 'Confirmar Docente',
      'confirm_classroom': 'Confirmar Aula',
      'confirm_data': 'Confirmar Datos',
      'view_all_classrooms': 'Ver Todas las Aulas',
      'view_map': 'Ver Mapa',
      'schedule_label': 'Horario',
      'group_division_required': 'División de grupos requerida',
      'group_division_message': 'El número de estudiantes excede la capacidad del aula. Deberá dividir en 2 grupos y seleccionar horarios independientes para cada uno.',
      
      // Career Options
      'systems_engineering': 'Ingeniería de Sistemas',
      'medicine': 'Medicina',
      'architecture': 'Arquitectura',
      'education': 'Educación',
      
      // ============== ADMIN ==============
      'campus': 'Sede',
      'faculty': 'Facultad',
      'classroom': 'Aula/Laboratorio',
      'software': 'Software',
      'requires_training': '¿Requiere capacitación?',
      'profile': 'Perfil',
      'reservations': 'Reservas',
      'schedule': 'Agendar',
      'settings': 'Configuraciones',
      'manage_classrooms': 'Administrar Aulas',
      'page_content': 'Contenido de Página',
      'schedule_management': 'Gestión de Horarios',
      'block_hours': 'Bloquear Horarios',
      'mark_unavailable': 'Marcar Horarios No Disponibles',
      'unavailable_hours_desc': 'Seleccione los horarios en los que el aula no estará disponible',
      'repeat_weekly': 'Repetir Semanalmente',
      'hours_selected': 'horario(s) seleccionado(s)',
      'mark_unavailable_btn': 'Marcar No Disponible(s)',
      'blocked_schedule': 'Horario Bloqueado',
      'delete_block': 'Eliminar Bloqueo',
      'current_week': 'Semana Actual',
      'previous_week': 'Semana Anterior',
      'next_week': 'Semana Siguiente',
      
      // Campus Options
      'cuenca': 'Cuenca',
      'azogues': 'Azogues',
      
      // Faculty Options
      'engineering': 'Ingenierías',
      'medicine_school': 'Medicina',
      'education_school': 'Educación',
      
      // ============== TIME SLOTS ==============
      'hour': 'Hora',
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mié',
      'thursday': 'Jue',
      'friday': 'Vie',
      
      // ============== MESSAGES ==============
      'please_complete': 'Por favor complete todos los campos y seleccione al menos un horario',
      'booking_confirmed': 'Reserva confirmada exitosamente',
      'booking_canceled': 'Reserva cancelada',
      'required_field': 'Campo obligatorio',
      'select_teacher_first': 'Por favor seleccione un docente',
      'select_classroom_first': 'Por favor seleccione un aula',
      'select_schedule_first': 'Selecciona día y hora antes de agendar.',
      'complete_all_fields': 'Por favor, completa todos los campos.',
      'booking_saved_success': 'Agendamiento guardado con éxito',
      'booking_save_error': 'Error al guardar el agendamiento',
      'confirm_booking_message': '¿Está seguro de confirmar esta reserva? Se enviará un correo de confirmación al administrador y al docente.',
      'email_confirmation_sent': 'Se ha enviado un correo de confirmación.',
      
      // ============== ORGANIZATION ==============
      'uc_name': 'Universidad Católica de Cuenca',
      'ite_name': 'Instituto de Investigación y Emprendimiento',
      'ite_vr': 'ITE VR',
      'innovation_department': 'Jefatura de Innovación y Emprendimiento',
      'vr_classroom': 'Aula Virtual',
      
      // ============== PROFILE ==============
      'personal_data': 'Datos Personales',
      'first_name': 'Nombres',
      'last_name': 'Apellidos',
      'email': 'Email',
      'phone': 'Teléfono',
      'position': 'Cargo',
      'save_changes': 'Guardar Cambios',
      'registered_teachers': 'Docentes Registrados',
      'no_teachers_registered': 'No hay docentes registrados',
      'add_new_teacher': 'Agregar Nuevo Docente',
      'edit_teacher': 'Editar Docente',
      'update_teacher': 'Actualizar Docente',
      'teacher_updated': 'Docente actualizado exitosamente',
      'teacher_deleted': 'Docente eliminado exitosamente',
      'confirm_delete_teacher': '¿Está seguro de eliminar este docente?',
      
      // ============== BOOKINGS ==============
      'my_bookings': 'Mis Agendas',
      'no_bookings': 'No tienes agendas programadas',
      'delete_selected': 'Eliminar Seleccionadas',
      'edit_booking': 'Editar Agenda',
      'update_booking': 'Actualizar Agenda',
      'booking_updated': 'Agenda actualizada exitosamente',
      'confirm_delete_booking': '¿Eliminar esta agenda?',
      'confirm_delete_bookings': '¿Está seguro de eliminar las agendas seleccionadas?',
      'booking_details': 'Detalles de la Reserva',
      'booking_type': 'Tipo',
      'booking_status': 'Estado',
      'regular_class': 'Clase Regular',
      'lunch_hour': 'Hora de Almuerzo',
      'blocked_schedule_type': 'Horario Bloqueado',
      'status_active': 'Activa',
      'status_cancelled': 'Cancelada',
      'created_by': 'Creado por',
      'cancel_full_booking': 'Cancelar Reserva Completa',
      'booking_cancelled_success': 'Reserva cancelada exitosamente',
      'confirm_cancel_booking': '¿Está seguro de cancelar esta reserva completa?',
      
      // ============== TRAINING MODAL ==============
      'welcome_ite_vr': '¡Bienvenido al Aula ITE VR!',
      'first_time_system': 'Primera vez en el sistema',
      'have_received_training': '¿Ha recibido capacitación sobre el uso de los equipos VR?',
      'yes_received_training': 'Sí, he recibido capacitación',
      'no_need_training': 'No, necesito capacitación',
      'training_request': 'Solicitud de Capacitación',
      'complete_training_form': 'Complete el formulario para programar su capacitación',
      'tentative_date': 'Fecha Tentativa',
      'topics_of_interest': 'Temas de Interés',
      'topics_placeholder': 'Describa los temas o aspectos específicos en los que necesita capacitación...',
      'submit_request': 'Enviar Solicitud',
      'training_request_sent': 'Su solicitud de capacitación ha sido enviada exitosamente',
      'select_training_option': 'Por favor seleccione si ha recibido capacitación',
      'complete_all_training_fields': 'Por favor complete todos los campos del formulario',
      
      // ============== MISC ==============
      'schedule_session': 'Agenda tu sesión ahora',
      'booking_system': 'Sistema de Agendamiento de Aulas VR',
      'dark_mode': 'Modo Oscuro',
      'light_mode': 'Modo Claro',
      'not_available': 'NO DISPONIBLE',
      'lunch': 'ALMUERZO',
      'cancelled': 'CANCELADA',
      'group_single': 'Grupo único',
      'groups_1_and_2': 'Grupos 1 y 2',
    },
    
    'en': {
      // ============== NAVIGATION & COMMON ==============
      'login': 'Login',
      'logout': 'Logout',
      'welcome': 'Welcome to ITE VR',
      'continue_btn': 'Continue',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'back': 'Back',
      'next': 'Next',
      'menu': 'Menu',
      'close': 'Close',
      'edit': 'Edit',
      'delete': 'Delete',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // ============== LANDING PAGE ==============
      'who_we_are': 'Who We Are?',
      'what_we_do': 'What We Do?',
      'schedule_now': 'Schedule Now',
      'who_we_are_text': 'We are the Virtual Reality laboratory of the Research and Entrepreneurship Institute (ITE) at Universidad Católica de Cuenca. We are dedicated to providing immersive learning experiences using cutting-edge technology.',
      'what_we_do_text': 'We offer access to our VR laboratories for teachers and students. We facilitate immersive educational sessions in various areas of knowledge, from anatomy to architecture, using state-of-the-art equipment.',
      
      // Features
      'easy_booking': 'Easy Booking',
      'easy_booking_desc': 'Online scheduling system available 24/7',
      'training_included': 'Training Included',
      'training_included_desc': 'Prior training for teachers in VR equipment use',
      'advanced_tech': 'Advanced Technology',
      'advanced_tech_desc': 'Meta Quest 3 equipment and specialized educational software',
      
      // Stats
      'laboratories': 'Laboratories',
      'vr_equipment': 'VR Equipment',
      'sessions_per_month': 'Sessions/month',
      
      // CTA
      'ready_to_innovate': 'Ready to innovate in your class?',
      'cta_description': 'Schedule your VR lab and take education to the next level',
      'start_now': 'Start Now',
      
      // Footer
      'quick_links': 'Quick Links',
      'about_us': 'About Us',
      'services': 'Services',
      'contact': 'Contact',
      'follow_us': 'Follow Us',
      'all_rights_reserved': 'All rights reserved',
      
      // VR Equipment
      'our_vr_equipment': 'Our VR Equipment',
      'vr_equipment_desc': 'We have the latest virtual reality technology for immersive educational experiences',
      'equipment_availability': 'Equipment Availability',
      'total_devices': 'Total: 15 virtual reality devices available for booking',
      
      // ============== LOGIN PAGE ==============
      'login_title': 'Login',
      'login_subtitle': 'Access with your university credentials',
      'secure_access': 'Secure Access',
      'secure_access_desc': 'Authentication with university credentials',
      'real_time_booking': 'Real-Time Booking',
      'real_time_booking_desc': 'View availability and schedule instantly',
      'fast_process': 'Fast Process',
      'fast_process_desc': 'Complete your reservation in less than 3 minutes',
      'demo_mode': 'Demo Mode',
      'demo_mode_text': 'In production, the institutional authentication system (SSO) will be integrated here.',
      'institutional_email': 'Institutional Email',
      'password': 'Password',
      'forgot_password': 'Forgot your password?',
      'need_help': 'Need help?',
      'contact_support': 'Contact support',
      'test_users': 'Test users:',
      'teacher_user': 'Teacher',
      'admin_user': 'Admin',
      'invalid_credentials': 'Invalid username or password',
      'welcome_scheduling_system': 'Welcome to the Scheduling System',
      
      // ============== TEACHER SCHEDULING ==============
      'enter_class_data': 'Enter class details',
      'complete_form_to_book': 'Complete the form to book',
      'training_required': 'I confirm that I understand that prior training is required to use the VR laboratory',
      'training_mandatory': 'Training is mandatory to use the equipment',
      'teacher_info': 'Teacher Information',
      'teacher_name': 'Teacher Name',
      'enter_full_name': 'Enter your full name',
      'select_lab': 'Select Laboratory',
      'location': 'Location',
      'capacity': 'Capacity',
      'max_capacity': 'Maximum capacity',
      'students': 'students',
      'class_details': 'Class Details',
      'subject': 'Subject',
      'subject_placeholder': 'E.g: Human Anatomy',
      'career': 'Program',
      'parallel': 'Parallel',
      'cycle': 'Cycle',
      'group': 'Group',
      'num_students': 'Number of Students',
      'group_explanation': 'For classes with more than 15 students, you must divide into 2 groups',
      'select_schedule': 'Select Schedule',
      'week': 'Week of',
      'available': 'Available',
      'selected': 'Selected',
      'occupied': 'Occupied',
      'confirm_booking': 'Confirm Booking',
      'select_option': 'Select...',
      'confirm_teacher': 'Confirm Teacher',
      'confirm_classroom': 'Confirm Classroom',
      'confirm_data': 'Confirm Data',
      'view_all_classrooms': 'View All Classrooms',
      'view_map': 'View Map',
      'schedule_label': 'Schedule',
      'group_division_required': 'Group division required',
      'group_division_message': 'The number of students exceeds the classroom capacity. You must divide into 2 groups and select independent schedules for each.',
      
      // Career Options
      'systems_engineering': 'Systems Engineering',
      'medicine': 'Medicine',
      'architecture': 'Architecture',
      'education': 'Education',
      
      // ============== ADMIN ==============
      'campus': 'Campus',
      'faculty': 'Faculty',
      'classroom': 'Classroom/Lab',
      'software': 'Software',
      'requires_training': 'Requires training?',
      'profile': 'Profile',
      'reservations': 'Reservations',
      'schedule': 'Schedule',
      'settings': 'Settings',
      'manage_classrooms': 'Manage Classrooms',
      'page_content': 'Page Content',
      'schedule_management': 'Schedule Management',
      'block_hours': 'Block Hours',
      'mark_unavailable': 'Mark Hours Unavailable',
      'unavailable_hours_desc': 'Select the hours when the classroom will not be available',
      'repeat_weekly': 'Repeat Weekly',
      'hours_selected': 'hour(s) selected',
      'mark_unavailable_btn': 'Mark Unavailable',
      'blocked_schedule': 'Blocked Schedule',
      'delete_block': 'Delete Block',
      'current_week': 'Current Week',
      'previous_week': 'Previous Week',
      'next_week': 'Next Week',
      
      // Campus Options
      'cuenca': 'Cuenca',
      'azogues': 'Azogues',
      
      // Faculty Options
      'engineering': 'Engineering',
      'medicine_school': 'Medicine',
      'education_school': 'Education',
      
      // ============== TIME SLOTS ==============
      'hour': 'Hour',
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      
      // ============== MESSAGES ==============
      'please_complete': 'Please complete all fields and select at least one time slot',
      'booking_confirmed': 'Booking confirmed successfully',
      'booking_canceled': 'Booking canceled',
      'required_field': 'Required field',
      'select_teacher_first': 'Please select a teacher',
      'select_classroom_first': 'Please select a classroom',
      'select_schedule_first': 'Select day and time before booking.',
      'complete_all_fields': 'Please complete all fields.',
      'booking_saved_success': 'Booking saved successfully',
      'booking_save_error': 'Error saving booking',
      'confirm_booking_message': 'Are you sure you want to confirm this booking? A confirmation email will be sent to the administrator and teacher.',
      'email_confirmation_sent': 'A confirmation email has been sent.',
      
      // ============== ORGANIZATION ==============
      'uc_name': 'Universidad Católica de Cuenca',
      'ite_name': 'Research and Entrepreneurship Institute',
      'ite_vr': 'ITE VR',
      'innovation_department': 'Innovation and Entrepreneurship Department',
      'vr_classroom': 'Virtual Classroom',
      
      // ============== PROFILE ==============
      'personal_data': 'Personal Data',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'email': 'Email',
      'phone': 'Phone',
      'position': 'Position',
      'save_changes': 'Save Changes',
      'registered_teachers': 'Registered Teachers',
      'no_teachers_registered': 'No teachers registered',
      'add_new_teacher': 'Add New Teacher',
      'edit_teacher': 'Edit Teacher',
      'update_teacher': 'Update Teacher',
      'teacher_updated': 'Teacher updated successfully',
      'teacher_deleted': 'Teacher deleted successfully',
      'confirm_delete_teacher': 'Are you sure you want to delete this teacher?',
      
      // ============== BOOKINGS ==============
      'my_bookings': 'My Bookings',
      'no_bookings': 'You have no scheduled bookings',
      'delete_selected': 'Delete Selected',
      'edit_booking': 'Edit Booking',
      'update_booking': 'Update Booking',
      'booking_updated': 'Booking updated successfully',
      'confirm_delete_booking': 'Delete this booking?',
      'confirm_delete_bookings': 'Are you sure you want to delete the selected bookings?',
      'booking_details': 'Booking Details',
      'booking_type': 'Type',
      'booking_status': 'Status',
      'regular_class': 'Regular Class',
      'lunch_hour': 'Lunch Hour',
      'blocked_schedule_type': 'Blocked Schedule',
      'status_active': 'Active',
      'status_cancelled': 'Cancelled',
      'created_by': 'Created by',
      'cancel_full_booking': 'Cancel Full Booking',
      'booking_cancelled_success': 'Booking cancelled successfully',
      'confirm_cancel_booking': 'Are you sure you want to cancel this full booking?',
      
      // ============== TRAINING MODAL ==============
      'welcome_ite_vr': 'Welcome to ITE VR Classroom!',
      'first_time_system': 'First time in the system',
      'have_received_training': 'Have you received training on VR equipment use?',
      'yes_received_training': 'Yes, I have received training',
      'no_need_training': 'No, I need training',
      'training_request': 'Training Request',
      'complete_training_form': 'Complete the form to schedule your training',
      'tentative_date': 'Tentative Date',
      'topics_of_interest': 'Topics of Interest',
      'topics_placeholder': 'Describe the specific topics or aspects you need training on...',
      'submit_request': 'Submit Request',
      'training_request_sent': 'Your training request has been sent successfully',
      'select_training_option': 'Please select if you have received training',
      'complete_all_training_fields': 'Please complete all form fields',
      
      // ============== MISC ==============
      'schedule_session': 'Schedule your session now',
      'booking_system': 'VR Laboratory Booking System',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'not_available': 'NOT AVAILABLE',
      'lunch': 'LUNCH',
      'cancelled': 'CANCELLED',
      'group_single': 'Single group',
      'groups_1_and_2': 'Groups 1 and 2',
    },
  };

  /// Obtiene una traducción por clave e idioma
  static String get(String key, String languageCode) {
    return _translations[languageCode]?[key] ?? 
           _translations['es']?[key] ?? 
           key;
  }

  /// Clase helper para acceder a las traducciones de forma tipada
  static AppStrings of(String languageCode) {
    return AppStrings(languageCode);
  }
}

/// Helper class para acceso tipado a traducciones
class AppStrings {
  final String _lang;
  
  AppStrings(this._lang);
  
  String _get(String key) => AppTranslations.get(key, _lang);
  
  // Navigation & Common
  String get login => _get('login');
  String get logout => _get('logout');
  String get welcome => _get('welcome');
  String get continueBtn => _get('continue_btn');
  String get cancel => _get('cancel');
  String get confirm => _get('confirm');
  String get save => _get('save');
  String get back => _get('back');
  String get next => _get('next');
  String get menu => _get('menu');
  String get close => _get('close');
  String get edit => _get('edit');
  String get delete => _get('delete');
  String get add => _get('add');
  String get search => _get('search');
  String get loading => _get('loading');
  String get error => _get('error');
  String get success => _get('success');
  
  // Landing Page
  String get whoWeAre => _get('who_we_are');
  String get whatWeDo => _get('what_we_do');
  String get scheduleNow => _get('schedule_now');
  String get whoWeAreText => _get('who_we_are_text');
  String get whatWeDoText => _get('what_we_do_text');
  String get easyBooking => _get('easy_booking');
  String get easyBookingDesc => _get('easy_booking_desc');
  String get trainingIncluded => _get('training_included');
  String get trainingIncludedDesc => _get('training_included_desc');
  String get advancedTech => _get('advanced_tech');
  String get advancedTechDesc => _get('advanced_tech_desc');
  String get laboratories => _get('laboratories');
  String get vrEquipment => _get('vr_equipment');
  String get sessionsPerMonth => _get('sessions_per_month');
  String get readyToInnovate => _get('ready_to_innovate');
  String get ctaDescription => _get('cta_description');
  String get startNow => _get('start_now');
  String get quickLinks => _get('quick_links');
  String get aboutUs => _get('about_us');
  String get services => _get('services');
  String get contact => _get('contact');
  String get followUs => _get('follow_us');
  String get allRightsReserved => _get('all_rights_reserved');
  String get ourVrEquipment => _get('our_vr_equipment');
  String get vrEquipmentDesc => _get('vr_equipment_desc');
  String get equipmentAvailability => _get('equipment_availability');
  String get totalDevices => _get('total_devices');
  
  // Login Page
  String get loginTitle => _get('login_title');
  String get loginSubtitle => _get('login_subtitle');
  String get secureAccess => _get('secure_access');
  String get secureAccessDesc => _get('secure_access_desc');
  String get realTimeBooking => _get('real_time_booking');
  String get realTimeBookingDesc => _get('real_time_booking_desc');
  String get fastProcess => _get('fast_process');
  String get fastProcessDesc => _get('fast_process_desc');
  String get demoMode => _get('demo_mode');
  String get demoModeText => _get('demo_mode_text');
  String get institutionalEmail => _get('institutional_email');
  String get password => _get('password');
  String get forgotPassword => _get('forgot_password');
  String get needHelp => _get('need_help');
  String get contactSupport => _get('contact_support');
  String get testUsers => _get('test_users');
  String get teacherUser => _get('teacher_user');
  String get adminUser => _get('admin_user');
  String get invalidCredentials => _get('invalid_credentials');
  String get welcomeSchedulingSystem => _get('welcome_scheduling_system');
  
  // Teacher Scheduling
  String get enterClassData => _get('enter_class_data');
  String get completeFormToBook => _get('complete_form_to_book');
  String get trainingRequired => _get('training_required');
  String get trainingMandatory => _get('training_mandatory');
  String get teacherInfo => _get('teacher_info');
  String get teacherName => _get('teacher_name');
  String get enterFullName => _get('enter_full_name');
  String get selectLab => _get('select_lab');
  String get location => _get('location');
  String get capacity => _get('capacity');
  String get maxCapacity => _get('max_capacity');
  String get students => _get('students');
  String get classDetails => _get('class_details');
  String get subject => _get('subject');
  String get subjectPlaceholder => _get('subject_placeholder');
  String get career => _get('career');
  String get parallel => _get('parallel');
  String get cycle => _get('cycle');
  String get group => _get('group');
  String get numStudents => _get('num_students');
  String get groupExplanation => _get('group_explanation');
  String get selectSchedule => _get('select_schedule');
  String get week => _get('week');
  String get available => _get('available');
  String get selected => _get('selected');
  String get occupied => _get('occupied');
  String get confirmBooking => _get('confirm_booking');
  String get selectOption => _get('select_option');
  String get confirmTeacher => _get('confirm_teacher');
  String get confirmClassroom => _get('confirm_classroom');
  String get confirmData => _get('confirm_data');
  String get viewAllClassrooms => _get('view_all_classrooms');
  String get viewMap => _get('view_map');
  String get scheduleLabel => _get('schedule_label');
  String get groupDivisionRequired => _get('group_division_required');
  String get groupDivisionMessage => _get('group_division_message');
  
  // Organization
  String get ucName => _get('uc_name');
  String get iteName => _get('ite_name');
  String get iteVr => _get('ite_vr');
  String get innovationDepartment => _get('innovation_department');
  String get vrClassroom => _get('vr_classroom');
  
  // Time Slots
  String get hour => _get('hour');
  String get monday => _get('monday');
  String get tuesday => _get('tuesday');
  String get wednesday => _get('wednesday');
  String get thursday => _get('thursday');
  String get friday => _get('friday');
  
  // Messages
  String get pleaseComplete => _get('please_complete');
  String get bookingConfirmed => _get('booking_confirmed');
  String get bookingCanceled => _get('booking_canceled');
  String get requiredField => _get('required_field');
  
  // Misc
  String get darkMode => _get('dark_mode');
  String get lightMode => _get('light_mode');
  String get notAvailable => _get('not_available');
  String get lunch => _get('lunch');
  String get cancelled => _get('cancelled');
}
