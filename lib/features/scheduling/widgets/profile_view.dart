import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

/// Vista de perfil de usuario con gestión de administradores y docentes
class ProfileView extends StatefulWidget {
  final bool isAdmin;
  
  const ProfileView({super.key, required this.isAdmin});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controladores para el formulario de perfil
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facultyController = TextEditingController();
  final _positionController = TextEditingController();
  
  // Estado de carga
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _filterFaculty = 'all';
  bool _filterTraining = false;

  // Mock teachers for admin
  final List<Map<String, dynamic>> _teachers = [
    {
      'id': '1',
      'firstName': 'Juan',
      'lastName': 'Pérez',
      'email': 'juan.perez@ucacue.edu.ec',
      'phone': '0999999999',
      'position': 'Docente Titular',
      'faculty': 'Ingeniería',
      'career': 'Sistemas',
      'subject': 'Programación',
      'hasTraining': true,
      'trainingDate': '2024-01-15',
    },
    {
      'id': '2',
      'firstName': 'María',
      'lastName': 'García',
      'email': 'maria.garcia@ucacue.edu.ec',
      'phone': '0988888888',
      'position': 'Docente',
      'faculty': 'Medicina',
      'career': 'Medicina General',
      'subject': 'Anatomía',
      'hasTraining': false,
      'trainingDate': null,
    },
    {
      'id': '3',
      'firstName': 'Carlos',
      'lastName': 'López',
      'email': 'carlos.lopez@ucacue.edu.ec',
      'phone': '0977777777',
      'position': 'Docente',
      'faculty': 'Ingeniería',
      'career': 'Civil',
      'subject': 'Estructuras',
      'hasTraining': true,
      'trainingDate': '2024-02-20',
    },
  ];

  // Mock admins
  final List<Map<String, dynamic>> _admins = [
    {
      'id': 'a1',
      'firstName': 'Admin',
      'lastName': 'Principal',
      'email': 'admin@ucacue.edu.ec',
      'phone': '0999999999',
      'role': 'superAdmin',
      'createdAt': '2024-01-01',
    },
    {
      'id': 'a2',
      'firstName': 'Operador',
      'lastName': 'VR',
      'email': 'operador@ucacue.edu.ec',
      'phone': '0988888888',
      'role': 'admin',
      'createdAt': '2024-03-15',
    },
  ];

  List<Map<String, dynamic>> get _filteredTeachers {
    return _teachers.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          '${t['firstName']} ${t['lastName']}'.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (t['email'] as String).toLowerCase()
              .contains(_searchQuery.toLowerCase());
      
      final matchesFaculty = _filterFaculty == 'all' || 
          t['faculty'] == _filterFaculty;
      
      final matchesTraining = !_filterTraining || 
          t['hasTraining'] == true;
      
      return matchesSearch && matchesFaculty && matchesTraining;
    }).toList();
  }

  Set<String> get _faculties {
    return _teachers.map((t) => t['faculty'] as String).toSet();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isAdmin ? 3 : 1, 
      vsync: this,
    );
    _loadUserProfile();
  }
  
  /// Carga el perfil del usuario actual
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Simular carga de datos (en producción, llamar al servicio)
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Datos del usuario según el tipo
      if (widget.isAdmin) {
        _firstNameController.text = 'Admin';
        _lastNameController.text = 'Sistema';
        _emailController.text = 'admin@ucacue.edu.ec';
        _phoneController.text = '0999999999';
        _facultyController.text = 'Administración';
        _positionController.text = 'Administrador del Sistema';
      } else {
        _firstNameController.text = 'Docente';
        _lastNameController.text = 'Demo';
        _emailController.text = 'docente@ucacue.edu.ec';
        _phoneController.text = '0998888888';
        _facultyController.text = 'Ingeniería';
        _positionController.text = 'Docente Titular';
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar el perfil: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _facultyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    // Mostrar indicador de carga
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              isSpanish ? 'Cargando perfil...' : 'Loading profile...',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    // Mostrar mensaje de error
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadUserProfile,
              icon: const Icon(LucideIcons.refreshCw),
              label: Text(isSpanish ? 'Reintentar' : 'Retry'),
            ),
          ],
        ),
      );
    }

    // Para docentes: mostrar datos personales + tabla de docentes registrados
    if (!widget.isAdmin) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalDataCard(isDark, isSpanish),
            const SizedBox(height: 24),
            _buildTeachersListForTeacher(isDark, isSpanish),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildTabBar(isDark, isSpanish),
        // Usar SizedBox en lugar de Expanded para evitar conflicto con SingleChildScrollView padre
        SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildPersonalDataCard(isDark, isSpanish),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildTeachersSection(isDark, isSpanish),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildAdminsSection(isDark, isSpanish),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDark, bool isSpanish) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark 
            ? AppColors.darkTextSecondary 
            : AppColors.lightTextSecondary,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(
            icon: const Icon(LucideIcons.user, size: 18),
            text: isSpanish ? 'Mi Perfil' : 'My Profile',
          ),
          Tab(
            icon: const Icon(LucideIcons.graduationCap, size: 18),
            text: isSpanish ? 'Docentes' : 'Teachers',
          ),
          Tab(
            icon: const Icon(LucideIcons.shield, size: 18),
            text: isSpanish ? 'Administradores' : 'Administrators',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataCard(bool isDark, bool isSpanish) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Text(
                    '${_firstNameController.text[0]}${_lastNameController.text[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSpanish ? 'Datos Personales' : 'Personal Data',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark 
                            ? AppColors.darkTextPrimary 
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.isAdmin 
                            ? (isSpanish ? 'Administrador' : 'Administrator')
                            : (isSpanish ? 'Docente' : 'Teacher'),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Form fields
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Nombres' : 'First Name',
                  controller: _firstNameController,
                  prefixIcon: LucideIcons.user,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Apellidos' : 'Last Name',
                  controller: _lastNameController,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Correo Electrónico' : 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: LucideIcons.mail,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Teléfono' : 'Phone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: LucideIcons.phone,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Facultad' : 'Faculty',
                  controller: _facultyController,
                  prefixIcon: LucideIcons.building,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Cargo' : 'Position',
                  controller: _positionController,
                  prefixIcon: LucideIcons.briefcase,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              AppButton(
                text: isSpanish ? 'Guardar Cambios' : 'Save Changes',
                icon: LucideIcons.save,
                onPressed: _handleSaveProfile,
              ),
              // Solo mostrar cambio de contraseña para admins
              if (widget.isAdmin) ...[
                const SizedBox(width: 12),
                AppSecondaryButton(
                  text: isSpanish ? 'Cambiar Contraseña' : 'Change Password',
                  onPressed: () => _handleChangePassword(isSpanish),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersSection(bool isDark, bool isSpanish) {
    return Column(
      children: [
        // Search and filters
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      hintText: isSpanish 
                          ? 'Buscar por nombre o email...' 
                          : 'Search by name or email...',
                      prefixIcon: LucideIcons.search,
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFacultyDropdown(isDark, isSpanish),
                  ),
                  const SizedBox(width: 12),
                  _buildTrainingFilter(isDark, isSpanish),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Stats row
        _buildTeacherStats(isDark, isSpanish),
        
        const SizedBox(height: 16),
        
        // Teachers table
        _buildTeachersTable(isDark, isSpanish),
      ],
    );
  }

  Widget _buildFacultyDropdown(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCardBackground 
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _filterFaculty,
          dropdownColor: isDark 
              ? AppColors.darkCardBackground 
              : AppColors.lightCardBackground,
          items: [
            DropdownMenuItem(
              value: 'all',
              child: Text(
                isSpanish ? 'Todas las facultades' : 'All faculties',
                style: TextStyle(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            ..._faculties.map((f) => DropdownMenuItem(
              value: f,
              child: Text(
                f,
                style: TextStyle(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.lightTextPrimary,
                ),
              ),
            )),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _filterFaculty = v);
          },
        ),
      ),
    );
  }

  Widget _buildTrainingFilter(bool isDark, bool isSpanish) {
    return FilterChip(
      label: Text(
        isSpanish ? 'Con capacitación' : 'Trained',
        style: TextStyle(
          color: _filterTraining 
              ? Colors.white 
              : (isDark 
                  ? AppColors.darkTextPrimary 
                  : AppColors.lightTextPrimary),
        ),
      ),
      selected: _filterTraining,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      onSelected: (v) => setState(() => _filterTraining = v),
    );
  }

  Widget _buildTeacherStats(bool isDark, bool isSpanish) {
    final total = _teachers.length;
    final trained = _teachers.where((t) => t['hasTraining'] == true).length;
    final pending = total - trained;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isDark,
            icon: LucideIcons.users,
            label: isSpanish ? 'Total Docentes' : 'Total Teachers',
            value: total.toString(),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            icon: LucideIcons.circleCheck,
            label: isSpanish ? 'Capacitados' : 'Trained',
            value: trained.toString(),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            icon: LucideIcons.clock,
            label: isSpanish ? 'Pendientes' : 'Pending',
            value: pending.toString(),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersTable(bool isDark, bool isSpanish) {
    final filtered = _filteredTeachers;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.graduationCap, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                isSpanish 
                    ? 'Docentes Registrados (${filtered.length})' 
                    : 'Registered Teachers (${filtered.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              AppButton(
                text: isSpanish ? 'Agregar Docente' : 'Add Teacher',
                icon: LucideIcons.userPlus,
                onPressed: () => _handleAddTeacher(isSpanish),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (filtered.isEmpty)
            _buildEmptyState(isDark, isSpanish, 'teachers')
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  isDark 
                      ? AppColors.darkCardBackground 
                      : AppColors.lightInputBg,
                ),
                columns: [
                  DataColumn(label: Text(isSpanish ? 'Nombre' : 'Name')),
                  DataColumn(label: Text(isSpanish ? 'Email' : 'Email')),
                  DataColumn(label: Text(isSpanish ? 'Facultad' : 'Faculty')),
                  DataColumn(label: Text(isSpanish ? 'Carrera' : 'Career')),
                  DataColumn(label: Text(isSpanish ? 'Capacitación' : 'Training')),
                  DataColumn(label: Text(isSpanish ? 'Acciones' : 'Actions')),
                ],
                rows: filtered.map((teacher) {
                  final hasTraining = teacher['hasTraining'] == true;
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                '${teacher['firstName'][0]}${teacher['lastName'][0]}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${teacher['firstName']} ${teacher['lastName']}'),
                          ],
                        ),
                      ),
                      DataCell(Text(teacher['email'] ?? '')),
                      DataCell(Text(teacher['faculty'] ?? '')),
                      DataCell(Text(teacher['career'] ?? '')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (hasTraining ? AppColors.success : AppColors.warning)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasTraining 
                                    ? LucideIcons.circleCheck 
                                    : LucideIcons.clock,
                                size: 14,
                                color: hasTraining 
                                    ? AppColors.success 
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasTraining 
                                    ? (isSpanish ? 'Completada' : 'Completed')
                                    : (isSpanish ? 'Pendiente' : 'Pending'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasTraining 
                                      ? AppColors.success 
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                LucideIcons.pencil, 
                                size: 18,
                                color: AppColors.primary,
                              ),
                              tooltip: isSpanish ? 'Editar' : 'Edit',
                              onPressed: () => _handleEditTeacher(teacher, isSpanish),
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.trash2, 
                                size: 18, 
                                color: AppColors.error,
                              ),
                              tooltip: isSpanish ? 'Eliminar' : 'Delete',
                              onPressed: () => _handleDeleteTeacher(teacher, isSpanish),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminsSection(bool isDark, bool isSpanish) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shield, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                isSpanish 
                    ? 'Administradores del Sistema' 
                    : 'System Administrators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              AppButton(
                text: isSpanish ? 'Agregar Admin' : 'Add Admin',
                icon: LucideIcons.userPlus,
                onPressed: () => _handleAddAdmin(isSpanish),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_admins.isEmpty)
            _buildEmptyState(isDark, isSpanish, 'admins')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _admins.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final admin = _admins[index];
                final isSuperAdmin = admin['role'] == 'superAdmin';
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.darkCardBackground 
                        : AppColors.lightCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSuperAdmin 
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : (isDark 
                              ? AppColors.darkBorder 
                              : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isSuperAdmin 
                            ? AppColors.primary 
                            : AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          isSuperAdmin 
                              ? LucideIcons.crown 
                              : LucideIcons.user,
                          color: isSuperAdmin 
                              ? Colors.white 
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${admin['firstName']} ${admin['lastName']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark 
                                        ? AppColors.darkTextPrimary 
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, 
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSuperAdmin 
                                        ? AppColors.primary 
                                        : AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isSuperAdmin 
                                        ? 'Super Admin' 
                                        : 'Admin',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isSuperAdmin 
                                          ? Colors.white 
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              admin['email'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark 
                                    ? AppColors.darkTextSecondary 
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isSuperAdmin)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                LucideIcons.pencil,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _handleEditAdmin(admin, isSpanish),
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: AppColors.error,
                              ),
                              onPressed: () => _handleDeleteAdmin(admin, isSpanish),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSpanish, String type) {
    final isTeachers = type == 'teachers';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              isTeachers ? LucideIcons.graduationCap : LucideIcons.shield,
              size: 64,
              color: isDark 
                  ? AppColors.darkTextMuted 
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isTeachers
                  ? (isSpanish 
                      ? 'No hay docentes registrados' 
                      : 'No teachers registered')
                  : (isSpanish 
                      ? 'No hay administradores' 
                      : 'No administrators'),
              style: TextStyle(
                fontSize: 16,
                color: isDark 
                    ? AppColors.darkTextMuted 
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tabla de docentes registrados para la vista del docente (no admin)
  Widget _buildTeachersListForTeacher(bool isDark, bool isSpanish) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.graduationCap,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSpanish ? 'Docentes Registrados' : 'Registered Teachers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  Text(
                    '${_teachers.length} ${isSpanish ? 'docentes' : 'teachers'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark 
                          ? AppColors.darkTextMuted 
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Tabla simple de docentes
          if (_teachers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 48,
                      color: isDark 
                          ? AppColors.darkTextMuted 
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSpanish 
                          ? 'No hay docentes registrados' 
                          : 'No teachers registered',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                            ? AppColors.darkTextMuted 
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Column(
                  children: [
                    // Header row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 12,
                      ),
                      color: isDark 
                          ? AppColors.darkBackground 
                          : AppColors.lightInputBg,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              isSpanish ? 'Nombre' : 'Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark 
                                    ? AppColors.darkTextMuted 
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              isSpanish ? 'Facultad' : 'Faculty',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark 
                                    ? AppColors.darkTextMuted 
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              isSpanish ? 'Carrera' : 'Career',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark 
                                    ? AppColors.darkTextMuted 
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              isSpanish ? 'Acciones' : 'Actions',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark 
                                    ? AppColors.darkTextMuted 
                                    : AppColors.lightTextSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Data rows
                    ...List.generate(_teachers.length, (index) {
                      final teacher = _teachers[index];
                      final isEven = index % 2 == 0;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isEven
                              ? (isDark ? AppColors.darkCard : Colors.white)
                              : (isDark 
                                  ? AppColors.darkBackground.withValues(alpha: 0.5) 
                                  : AppColors.lightInputBg.withValues(alpha: 0.5)),
                          border: index < _teachers.length - 1
                              ? Border(
                                  bottom: BorderSide(
                                    color: isDark 
                                        ? AppColors.darkBorder 
                                        : AppColors.lightBorder,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      '${(teacher['firstName'] as String)[0]}${(teacher['lastName'] as String)[0]}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${teacher['firstName']} ${teacher['lastName']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark 
                                                ? AppColors.darkText 
                                                : AppColors.lightText,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          teacher['email'] as String,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark 
                                                ? AppColors.darkTextMuted 
                                                : AppColors.lightTextSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                teacher['faculty'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark 
                                      ? AppColors.darkText 
                                      : AppColors.lightText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                teacher['career'] as String? ?? '-',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark 
                                      ? AppColors.darkText 
                                      : AppColors.lightText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Botones de acción
                            SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      LucideIcons.pencil,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () => _handleEditTeacherForTeacher(teacher, isDark, isSpanish),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    tooltip: isSpanish ? 'Editar' : 'Edit',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      LucideIcons.trash2,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () => _handleDeleteTeacherForTeacher(teacher, isDark, isSpanish),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    tooltip: isSpanish ? 'Eliminar' : 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Editar docente desde la vista de docente
  void _handleEditTeacherForTeacher(
    Map<String, dynamic> teacher, 
    bool isDark, 
    bool isSpanish,
  ) {
    final firstNameController = TextEditingController(text: teacher['firstName']);
    final lastNameController = TextEditingController(text: teacher['lastName']);
    final emailController = TextEditingController(text: teacher['email']);
    final phoneController = TextEditingController(text: teacher['phone'] ?? '');
    final facultyController = TextEditingController(text: teacher['faculty']);
    final careerController = TextEditingController(text: teacher['career'] ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.userPen, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isSpanish ? 'Editar Docente' : 'Edit Teacher',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: isSpanish ? 'Nombre *' : 'First Name *',
                        controller: firstNameController,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: isSpanish ? 'Apellido *' : 'Last Name *',
                        controller: lastNameController,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: isSpanish ? 'Correo *' : 'Email *',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: isSpanish ? 'Teléfono' : 'Phone',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: isSpanish ? 'Facultad *' : 'Faculty *',
                  controller: facultyController,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: isSpanish ? 'Carrera' : 'Career',
                  controller: careerController,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isSpanish ? 'Cancelar' : 'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (firstNameController.text.isEmpty ||
                  lastNameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  facultyController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(isSpanish ? 'Complete los campos obligatorios' : 'Fill required fields')),
                );
                return;
              }
              
              setState(() {
                final index = _teachers.indexWhere((t) => t['id'] == teacher['id']);
                if (index != -1) {
                  _teachers[index] = {
                    ..._teachers[index],
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'faculty': facultyController.text,
                    'career': careerController.text,
                  };
                }
              });
              
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isSpanish ? 'Docente actualizado' : 'Teacher updated'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isSpanish ? 'Guardar' : 'Save'),
          ),
        ],
      ),
    );
  }

  /// Eliminar docente desde la vista de docente
  void _handleDeleteTeacherForTeacher(
    Map<String, dynamic> teacher, 
    bool isDark, 
    bool isSpanish,
  ) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Eliminar docente?' : 'Delete teacher?',
      message: isSpanish 
          ? '¿Está seguro de eliminar a ${teacher['firstName']} ${teacher['lastName']}?' 
          : 'Are you sure you want to delete ${teacher['firstName']} ${teacher['lastName']}?',
      confirmText: isSpanish ? 'Eliminar' : 'Delete',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        _teachers.removeWhere((t) => t['id'] == teacher['id']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSpanish ? 'Docente eliminado' : 'Teacher deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _handleSaveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LocaleProvider>().isSpanish 
              ? 'Cambios guardados exitosamente' 
              : 'Changes saved successfully',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleChangePassword(bool isSpanish) async {
    // TODO: Implement password change modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSpanish 
              ? 'Funcionalidad próximamente' 
              : 'Feature coming soon',
        ),
      ),
    );
  }

  void _handleAddTeacher(bool isSpanish) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final phoneController = TextEditingController();
    final facultyController = TextEditingController();
    final careerController = TextEditingController();
    final trainingDateController = TextEditingController();
    
    bool hasTraining = true; // Por defecto está capacitado
    bool showPassword = false;
    bool showConfirmPassword = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.userPlus, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSpanish ? 'Agregar Docente' : 'Add Teacher',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y Apellido
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: isSpanish ? 'Nombre *' : 'First Name *',
                          hint: 'Juan',
                          controller: firstNameController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: isSpanish ? 'Apellido *' : 'Last Name *',
                          hint: 'Pérez',
                          controller: lastNameController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: isSpanish ? 'Correo Institucional *' : 'Institutional Email *',
                    hint: 'juan.perez@ucacue.edu.ec',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: LucideIcons.mail,
                  ),
                  const SizedBox(height: 12),
                  
                  // Sección de credenciales
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.keyRound, size: 16, color: AppColors.info),
                            const SizedBox(width: 8),
                            Text(
                              isSpanish ? 'Credenciales de Acceso' : 'Login Credentials',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSpanish 
                              ? 'El docente usará estas credenciales para iniciar sesión'
                              : 'Teacher will use these credentials to log in',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            labelText: isSpanish ? 'Contraseña *' : 'Password *',
                            hintText: isSpanish ? 'Mínimo 6 caracteres' : 'Minimum 6 characters',
                            prefixIcon: const Icon(LucideIcons.lock, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 18,
                              ),
                              onPressed: () => setDialogState(() => showPassword = !showPassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !showConfirmPassword,
                          decoration: InputDecoration(
                            labelText: isSpanish ? 'Confirmar Contraseña *' : 'Confirm Password *',
                            prefixIcon: const Icon(LucideIcons.lockKeyhole, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 18,
                              ),
                              onPressed: () => setDialogState(() => showConfirmPassword = !showConfirmPassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  AppTextField(
                    label: isSpanish ? 'Teléfono *' : 'Phone *',
                    hint: '0999999999',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: LucideIcons.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: isSpanish ? 'Facultad *' : 'Faculty *',
                          hint: 'Ej: Ingeniería',
                          controller: facultyController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: isSpanish ? 'Carrera *' : 'Career *',
                          hint: 'Ej: Sistemas',
                          controller: careerController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Toggle Sí/No para capacitación
                  Text(
                    isSpanish ? '¿Está capacitado para usar el Aula VR?' : 'Is trained to use VR Lab?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Botón Sí
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => hasTraining = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: hasTraining 
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : (isDark ? AppColors.darkBackground : AppColors.lightInputBg),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: hasTraining 
                                    ? AppColors.success 
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: hasTraining ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.circleCheck,
                                  size: 18,
                                  color: hasTraining 
                                      ? AppColors.success 
                                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isSpanish ? 'Sí' : 'Yes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: hasTraining 
                                        ? AppColors.success 
                                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón No
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => hasTraining = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !hasTraining 
                                  ? AppColors.warning.withValues(alpha: 0.1)
                                  : (isDark ? AppColors.darkBackground : AppColors.lightInputBg),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !hasTraining 
                                    ? AppColors.warning 
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: !hasTraining ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.clock,
                                  size: 18,
                                  color: !hasTraining 
                                      ? AppColors.warning 
                                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: !hasTraining 
                                        ? AppColors.warning 
                                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Formulario de fecha tentativa si NO está capacitado
                  if (!hasTraining) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.info, size: 16, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isSpanish 
                                      ? 'El docente no podrá agendar hasta completar la capacitación'
                                      : 'Teacher will not be able to book until training is complete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: isSpanish ? 'Fecha tentativa de capacitación' : 'Tentative training date',
                            hint: isSpanish ? 'Ej: 2024-02-15' : 'E.g: 2024-02-15',
                            controller: trainingDateController,
                            prefixIcon: LucideIcons.calendar,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                trainingDateController.text = 
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                              }
                            },
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                isSpanish ? 'Cancelar' : 'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Validación de campos básicos
                if (firstNameController.text.isEmpty ||
                    lastNameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    facultyController.text.isEmpty ||
                    careerController.text.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'Complete todos los campos obligatorios' : 'Complete all required fields'),
                    ),
                  );
                  return;
                }
                
                // Validar contraseña mínimo 6 caracteres
                if (passwordController.text.length < 6) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'La contraseña debe tener al menos 6 caracteres' : 'Password must be at least 6 characters'),
                    ),
                  );
                  return;
                }
                
                // Validar que las contraseñas coincidan
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'Las contraseñas no coinciden' : 'Passwords do not match'),
                    ),
                  );
                  return;
                }
                
                // Validar formato de email institucional
                if (!emailController.text.endsWith('@ucacue.edu.ec')) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'Use correo institucional (@ucacue.edu.ec)' : 'Use institutional email (@ucacue.edu.ec)'),
                    ),
                  );
                  return;
                }
                
                if (!hasTraining && trainingDateController.text.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'Ingrese fecha tentativa de capacitación' : 'Enter tentative training date'),
                    ),
                  );
                  return;
                }

                final newId = DateTime.now().millisecondsSinceEpoch.toString();
                setState(() {
                  _teachers.add({
                    'id': newId,
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'password': passwordController.text, // TODO: Backend hashea esto
                    'phone': phoneController.text,
                    'position': 'Docente',
                    'faculty': facultyController.text,
                    'career': careerController.text,
                    'role': 'teacher', // Rol para el backend
                    'hasTraining': hasTraining,
                    'trainingDate': hasTraining ? null : trainingDateController.text,
                  });
                });

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isSpanish ? 'Docente agregado exitosamente' : 'Teacher added successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Guardar' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditTeacher(Map<String, dynamic> teacher, bool isSpanish) {
    // TODO: Implement edit teacher modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${isSpanish ? 'Editar' : 'Edit'}: ${teacher['firstName']} ${teacher['lastName']}',
        ),
      ),
    );
  }

  void _handleDeleteTeacher(Map<String, dynamic> teacher, bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Eliminar docente?' : 'Delete teacher?',
      message: isSpanish
          ? '¿Está seguro de eliminar a ${teacher['firstName']} ${teacher['lastName']}? Esta acción no se puede deshacer.'
          : 'Are you sure you want to delete ${teacher['firstName']} ${teacher['lastName']}? This action cannot be undone.',
      confirmText: isSpanish ? 'Eliminar' : 'Delete',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        _teachers.removeWhere((t) => t['id'] == teacher['id']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSpanish ? 'Docente eliminado' : 'Teacher deleted',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _handleAddAdmin(bool isSpanish) async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedRole = 'admin';
    bool showPassword = false;
    bool showConfirmPassword = false;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.userPlus, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSpanish ? 'Agregar Administrador' : 'Add Administrator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: firstNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: isSpanish ? 'Nombre *' : 'First Name *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: lastNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: isSpanish ? 'Apellido *' : 'Last Name *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Correo electrónico *' : 'Email *',
                      hintText: 'admin@ucacue.edu.ec',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(LucideIcons.mail, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sección de credenciales
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Text(
                              isSpanish ? 'Credenciales de Acceso' : 'Login Credentials',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSpanish 
                              ? 'Este administrador tendrá acceso completo al panel'
                              : 'This admin will have full access to the panel',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordCtrl,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            labelText: isSpanish ? 'Contraseña *' : 'Password *',
                            hintText: isSpanish ? 'Mínimo 6 caracteres' : 'Minimum 6 characters',
                            prefixIcon: const Icon(LucideIcons.lock, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 18,
                              ),
                              onPressed: () => setDialogState(() => showPassword = !showPassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: confirmPasswordCtrl,
                          obscureText: !showConfirmPassword,
                          decoration: InputDecoration(
                            labelText: isSpanish ? 'Confirmar Contraseña *' : 'Confirm Password *',
                            prefixIcon: const Icon(LucideIcons.lockKeyhole, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 18,
                              ),
                              onPressed: () => setDialogState(() => showConfirmPassword = !showConfirmPassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Teléfono' : 'Phone',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(LucideIcons.phone, size: 18),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  DropdownMenu<String>(
                    initialSelection: selectedRole,
                    label: Text(isSpanish ? 'Rol *' : 'Role *'),
                    leadingIcon: const Icon(LucideIcons.shield, size: 18),
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: [
                      DropdownMenuEntry(
                        value: 'admin',
                        label: isSpanish ? 'Administrador' : 'Administrator',
                      ),
                      DropdownMenuEntry(
                        value: 'superAdmin',
                        label: 'Super Admin',
                      ),
                    ],
                    onSelected: (v) => setDialogState(() => selectedRole = v ?? 'admin'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validaciones
                if (firstNameCtrl.text.isEmpty || 
                    lastNameCtrl.text.isEmpty || 
                    emailCtrl.text.isEmpty ||
                    passwordCtrl.text.isEmpty ||
                    confirmPasswordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'Complete todos los campos obligatorios' : 'Complete all required fields'),
                    ),
                  );
                  return;
                }
                
                if (passwordCtrl.text.length < 6) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'La contraseña debe tener al menos 6 caracteres' : 'Password must be at least 6 characters'),
                    ),
                  );
                  return;
                }
                
                if (passwordCtrl.text != confirmPasswordCtrl.text) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'Las contraseñas no coinciden' : 'Passwords do not match'),
                    ),
                  );
                  return;
                }
                
                if (!emailCtrl.text.endsWith('@ucacue.edu.ec')) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(isSpanish ? 'Use correo institucional (@ucacue.edu.ec)' : 'Use institutional email (@ucacue.edu.ec)'),
                    ),
                  );
                  return;
                }
                
                Navigator.pop(ctx, {
                  'firstName': firstNameCtrl.text,
                  'lastName': lastNameCtrl.text,
                  'email': emailCtrl.text,
                  'password': passwordCtrl.text, // TODO: Backend hashea esto
                  'phone': phoneCtrl.text,
                  'role': selectedRole,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Agregar' : 'Add'),
            ),
          ],
        ),
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _admins.add({
          'id': 'a${DateTime.now().millisecondsSinceEpoch}',
          ...result,
          'createdAt': DateTime.now().toIso8601String().split('T')[0],
        });
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish ? 'Administrador agregado exitosamente' : 'Administrator added successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleEditAdmin(Map<String, dynamic> admin, bool isSpanish) async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final firstNameCtrl = TextEditingController(text: admin['firstName']);
    final lastNameCtrl = TextEditingController(text: admin['lastName']);
    final emailCtrl = TextEditingController(text: admin['email']);
    final phoneCtrl = TextEditingController(text: admin['phone']);
    String selectedRole = admin['role'] ?? 'admin';
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.userPen, color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                isSpanish ? 'Editar Administrador' : 'Edit Administrator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameCtrl,
                        decoration: InputDecoration(
                          labelText: isSpanish ? 'Nombre' : 'First Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lastNameCtrl,
                        decoration: InputDecoration(
                          labelText: isSpanish ? 'Apellido' : 'Last Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: isSpanish ? 'Correo electrónico' : 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(LucideIcons.mail),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: isSpanish ? 'Teléfono' : 'Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(LucideIcons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                if (admin['role'] != 'superAdmin')
                  DropdownMenu<String>(
                    initialSelection: selectedRole,
                    label: Text(isSpanish ? 'Rol' : 'Role'),
                    leadingIcon: const Icon(LucideIcons.shield),
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: [
                      DropdownMenuEntry(
                        value: 'admin',
                        label: isSpanish ? 'Administrador' : 'Administrator',
                      ),
                      DropdownMenuEntry(
                        value: 'operator',
                        label: isSpanish ? 'Operador' : 'Operator',
                      ),
                    ],
                    onSelected: (v) => setDialogState(() => selectedRole = v ?? 'admin'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (firstNameCtrl.text.isNotEmpty && 
                    lastNameCtrl.text.isNotEmpty && 
                    emailCtrl.text.isNotEmpty) {
                  Navigator.pop(ctx, {
                    'firstName': firstNameCtrl.text,
                    'lastName': lastNameCtrl.text,
                    'email': emailCtrl.text,
                    'phone': phoneCtrl.text,
                    'role': selectedRole,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Guardar' : 'Save'),
            ),
          ],
        ),
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        final index = _admins.indexWhere((a) => a['id'] == admin['id']);
        if (index != -1) {
          _admins[index] = {
            ..._admins[index],
            ...result,
          };
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish ? 'Cambios guardados' : 'Changes saved',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleDeleteAdmin(Map<String, dynamic> admin, bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Eliminar administrador?' : 'Delete administrator?',
      message: isSpanish
          ? '¿Está seguro de eliminar a ${admin['firstName']} ${admin['lastName']}?'
          : 'Are you sure you want to delete ${admin['firstName']} ${admin['lastName']}?',
      confirmText: isSpanish ? 'Eliminar' : 'Delete',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        _admins.removeWhere((a) => a['id'] == admin['id']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSpanish ? 'Administrador eliminado' : 'Administrator deleted',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
