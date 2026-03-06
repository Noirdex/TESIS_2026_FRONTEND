import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/core.dart';

/// Vista para administrar las Aulas VR (CRUD completo)
class AulasManagementView extends StatefulWidget {
  const AulasManagementView({super.key});

  @override
  State<AulasManagementView> createState() => _AulasManagementViewState();
}

class _AulasManagementViewState extends State<AulasManagementView> {
  String _searchQuery = '';
  bool _showInactive = false;
  
  // Mock aulas data
  final List<Aula> _aulas = [
    Aula(
      id: '1',
      name: 'Aula VR 1',
      location: 'Edificio A - Piso 2',
      capacity: 10,
      schedule: '07:00 - 16:00',
      availableDays: [1, 2, 3, 4, 5],
      isActive: true,
      description: 'Aula principal equipada con 10 estaciones de realidad virtual.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Aula(
      id: '2',
      name: 'Aula VR 2',
      location: 'Edificio B - Piso 1',
      capacity: 15,
      schedule: '08:00 - 17:00',
      availableDays: [1, 2, 3, 4, 5],
      isActive: true,
      description: 'Aula secundaria con equipamiento de última generación.',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    Aula(
      id: '3',
      name: 'Aula VR Principal',
      location: 'Edificio Central',
      capacity: 25,
      schedule: '07:00 - 18:00',
      availableDays: [1, 2, 3, 4, 5, 6],
      isActive: true,
      description: 'Aula de mayor capacidad, ideal para grupos grandes.',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    Aula(
      id: '4',
      name: 'Aula VR (Mantenimiento)',
      location: 'Edificio A - Piso 3',
      capacity: 8,
      schedule: '07:00 - 14:00',
      availableDays: [1, 2, 3, 4, 5],
      isActive: false,
      description: 'Temporalmente fuera de servicio por mantenimiento.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
  
  List<Aula> get _filteredAulas {
    return _aulas.where((a) {
      final matchesSearch = _searchQuery.isEmpty ||
          a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.location.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesActive = _showInactive || a.isActive;
      return matchesSearch && matchesActive;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.building, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSpanish ? 'Gestión de Aulas VR' : 'VR Classrooms Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSpanish 
                            ? 'Administra las aulas de realidad virtual: capacidad, horarios y disponibilidad.'
                            : 'Manage virtual reality classrooms: capacity, schedules and availability.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  text: isSpanish ? 'Nueva Aula' : 'New Classroom',
                  icon: LucideIcons.plus,
                  onPressed: () => _handleAddAula(isDark, isSpanish),
                ),
              ],
            ),
          ),
          
          // Stats
          _buildStats(isDark, isSpanish),
          
          const SizedBox(height: 24),
          
          // Filters
          AppCard(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: isSpanish ? 'Buscar aula...' : 'Search classroom...',
                    prefixIcon: LucideIcons.search,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _showInactive,
                      onChanged: (v) => setState(() => _showInactive = v ?? false),
                    ),
                    Text(
                      isSpanish ? 'Mostrar inactivas' : 'Show inactive',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Aulas grid
          if (_filteredAulas.isEmpty)
            _buildEmptyState(isDark, isSpanish)
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _filteredAulas.map((aula) => 
                _buildAulaCard(aula, isDark, isSpanish),
              ).toList(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStats(bool isDark, bool isSpanish) {
    final activeCount = _aulas.where((a) => a.isActive).length;
    final inactiveCount = _aulas.where((a) => !a.isActive).length;
    final totalCapacity = _aulas.where((a) => a.isActive).fold<int>(0, (sum, a) => sum + a.capacity);
    
    return Row(
      children: [
        _buildStatCard(
          icon: LucideIcons.building,
          label: isSpanish ? 'Aulas Activas' : 'Active Classrooms',
          value: '$activeCount',
          color: AppColors.success,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: LucideIcons.building2,
          label: isSpanish ? 'Inactivas' : 'Inactive',
          value: '$inactiveCount',
          color: AppColors.warning,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: LucideIcons.users,
          label: isSpanish ? 'Capacidad Total' : 'Total Capacity',
          value: '$totalCapacity',
          color: AppColors.info,
          isDark: isDark,
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAulaCard(Aula aula, bool isDark, bool isSpanish) {
    return SizedBox(
      width: 350,
      height: 280, // Altura fija para uniformidad
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: aula.isActive 
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.glasses,
                    color: aula.isActive ? AppColors.primary : AppColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              aula.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: aula.isActive 
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              aula.isActive 
                                  ? (isSpanish ? 'Activa' : 'Active')
                                  : (isSpanish ? 'Inactiva' : 'Inactive'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: aula.isActive ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        aula.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Info grid
            Row(
              children: [
                _buildInfoChip(
                  LucideIcons.users,
                  '${aula.capacity} ${isSpanish ? "personas" : "people"}',
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  LucideIcons.clock,
                  aula.schedule,
                  isDark,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Days
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    aula.availableDaysNames.join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ),
              ],
            ),
            
            if (aula.description != null) ...[
              const SizedBox(height: 12),
              Text(
                aula.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Spacer para empujar acciones al final
            const Spacer(),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    aula.isActive ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                  tooltip: aula.isActive 
                      ? (isSpanish ? 'Desactivar' : 'Deactivate')
                      : (isSpanish ? 'Activar' : 'Activate'),
                  onPressed: () => _handleToggleActive(aula, isSpanish),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 18,
                    color: AppColors.info,
                  ),
                  tooltip: isSpanish ? 'Editar' : 'Edit',
                  onPressed: () => _handleEditAula(aula, isDark, isSpanish),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: AppColors.error,
                  ),
                  tooltip: isSpanish ? 'Eliminar' : 'Delete',
                  onPressed: () => _handleDeleteAula(aula, isSpanish),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(bool isDark, bool isSpanish) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              LucideIcons.building,
              size: 64,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isSpanish ? 'No hay aulas registradas' : 'No classrooms registered',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: isSpanish ? 'Agregar Primera Aula' : 'Add First Classroom',
              icon: LucideIcons.plus,
              onPressed: () => _handleAddAula(isDark, isSpanish),
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleAddAula(bool isDark, bool isSpanish) async {
    final result = await _showAulaModal(null, isDark, isSpanish);
    
    if (result != null && mounted) {
      setState(() {
        _aulas.add(Aula(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result['name'],
          location: result['location'],
          capacity: result['capacity'],
          schedule: result['schedule'],
          lunchBreak: result['lunchBreak'],
          availableDays: result['availableDays'],
          imageUrl: result['imageUrl'],
          latitude: result['latitude'],
          longitude: result['longitude'],
          description: result['description'],
          isActive: true,
          createdAt: DateTime.now(),
        ));
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpanish ? 'Aula creada exitosamente' : 'Classroom created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
  
  void _handleEditAula(Aula aula, bool isDark, bool isSpanish) async {
    final result = await _showAulaModal(aula, isDark, isSpanish);
    
    if (result != null && mounted) {
      setState(() {
        final index = _aulas.indexWhere((a) => a.id == aula.id);
        if (index != -1) {
          _aulas[index] = aula.copyWith(
            name: result['name'],
            location: result['location'],
            capacity: result['capacity'],
            schedule: result['schedule'],
            lunchBreak: result['lunchBreak'],
            availableDays: result['availableDays'],
            imageUrl: result['imageUrl'],
            latitude: result['latitude'],
            longitude: result['longitude'],
            description: result['description'],
            updatedAt: DateTime.now(),
          );
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpanish ? 'Aula actualizada' : 'Classroom updated'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
  
  void _handleDeleteAula(Aula aula, bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Eliminar aula?' : 'Delete classroom?',
      message: isSpanish
          ? '¿Está seguro de eliminar "${aula.name}"? Esta acción no se puede deshacer.'
          : 'Are you sure you want to delete "${aula.name}"? This action cannot be undone.',
      confirmText: isSpanish ? 'Eliminar' : 'Delete',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        _aulas.removeWhere((a) => a.id == aula.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpanish ? 'Aula eliminada' : 'Classroom deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
  
  void _handleToggleActive(Aula aula, bool isSpanish) async {
    final action = aula.isActive 
        ? (isSpanish ? 'desactivar' : 'deactivate')
        : (isSpanish ? 'activar' : 'activate');
    
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿${aula.isActive ? "Desactivar" : "Activar"} aula?' : '${aula.isActive ? "Deactivate" : "Activate"} classroom?',
      message: isSpanish
          ? '¿Está seguro de $action "${aula.name}"?'
          : 'Are you sure you want to $action "${aula.name}"?',
      confirmText: isSpanish ? 'Confirmar' : 'Confirm',
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        final index = _aulas.indexWhere((a) => a.id == aula.id);
        if (index != -1) {
          _aulas[index] = aula.copyWith(
            isActive: !aula.isActive,
            updatedAt: DateTime.now(),
          );
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            aula.isActive 
                ? (isSpanish ? 'Aula desactivada' : 'Classroom deactivated')
                : (isSpanish ? 'Aula activada' : 'Classroom activated'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
  
  Future<Map<String, dynamic>?> _showAulaModal(Aula? aula, bool isDark, bool isSpanish) async {
    final nameCtrl = TextEditingController(text: aula?.name ?? '');
    final locationCtrl = TextEditingController(text: aula?.location ?? '');
    final capacityCtrl = TextEditingController(text: aula?.capacity.toString() ?? '');
    final descriptionCtrl = TextEditingController(text: aula?.description ?? '');
    // Imagen
    String? imageUrl = aula?.imageUrl;
    XFile? selectedImage;
    Uint8List? imagePreviewBytes;
    int startHour = aula?.scheduleHours.$1 ?? 7;
    int endHour = aula?.scheduleHours.$2 ?? 17;
    // Horario de almuerzo
    int? lunchStartHour = aula?.lunchBreakHours?.$1;
    int? lunchEndHour = aula?.lunchBreakHours?.$2;
    bool hasLunchBreak = lunchStartHour != null;
    // Coordenadas de mapa
    double? latitude = aula?.latitude;
    double? longitude = aula?.longitude;
    List<int> selectedDays = List.from(aula?.availableDays ?? [1, 2, 3, 4, 5]);
    
    return showDialog<Map<String, dynamic>>(
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
                child: Icon(
                  aula == null ? LucideIcons.plus : LucideIcons.pencil,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                aula == null 
                    ? (isSpanish ? 'Nueva Aula' : 'New Classroom')
                    : (isSpanish ? 'Editar Aula' : 'Edit Classroom'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
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
                  // Name
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Nombre del aula *' : 'Classroom name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(LucideIcons.building),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  TextField(
                    controller: locationCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Ubicación *' : 'Location *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(LucideIcons.mapPin),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Capacity
                  TextField(
                    controller: capacityCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Capacidad (personas) *' : 'Capacity (people) *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(LucideIcons.users),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  
                  // Schedule
                  Text(
                    isSpanish ? 'Horario de operación' : 'Operating hours',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownMenu<int>(
                          initialSelection: startHour,
                          label: Text(isSpanish ? 'Desde' : 'From'),
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: List.generate(12, (i) => i + 6).map((h) => DropdownMenuEntry(
                            value: h,
                            label: '${h.toString().padLeft(2, '0')}:00',
                          )).toList(),
                          onSelected: (v) => setDialogState(() => startHour = v ?? 7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownMenu<int>(
                          initialSelection: endHour,
                          label: Text(isSpanish ? 'Hasta' : 'To'),
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: List.generate(12, (i) => i + 12).map((h) => DropdownMenuEntry(
                            value: h,
                            label: '${h.toString().padLeft(2, '0')}:00',
                          )).toList(),
                          onSelected: (v) => setDialogState(() => endHour = v ?? 17),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Available days
                  Text(
                    isSpanish ? 'Días disponibles' : 'Available days',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in [
                        (1, 'Lun', 'Mon'),
                        (2, 'Mar', 'Tue'),
                        (3, 'Mié', 'Wed'),
                        (4, 'Jue', 'Thu'),
                        (5, 'Vie', 'Fri'),
                        (6, 'Sáb', 'Sat'),
                        (7, 'Dom', 'Sun'),
                      ])
                        FilterChip(
                          label: Text(isSpanish ? entry.$2 : entry.$3),
                          selected: selectedDays.contains(entry.$1),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedDays.add(entry.$1);
                              } else {
                                selectedDays.remove(entry.$1);
                              }
                              selectedDays.sort();
                            });
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Horario de almuerzo
                  Row(
                    children: [
                      Checkbox(
                        value: hasLunchBreak,
                        onChanged: (v) => setDialogState(() {
                          hasLunchBreak = v ?? false;
                          if (hasLunchBreak && lunchStartHour == null) {
                            lunchStartHour = 12;
                            lunchEndHour = 13;
                          }
                        }),
                      ),
                      Text(
                        isSpanish ? 'Horario de almuerzo' : 'Lunch break',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (hasLunchBreak) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownMenu<int>(
                            initialSelection: lunchStartHour ?? 12,
                            label: Text(isSpanish ? 'Desde' : 'From'),
                            expandedInsets: EdgeInsets.zero,
                            dropdownMenuEntries: List.generate(6, (i) => i + 11).map((h) => DropdownMenuEntry(
                              value: h,
                              label: '${h.toString().padLeft(2, '0')}:00',
                            )).toList(),
                            onSelected: (v) => setDialogState(() => lunchStartHour = v ?? 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownMenu<int>(
                            initialSelection: lunchEndHour ?? 13,
                            label: Text(isSpanish ? 'Hasta' : 'To'),
                            expandedInsets: EdgeInsets.zero,
                            dropdownMenuEntries: List.generate(6, (i) => i + 12).map((h) => DropdownMenuEntry(
                              value: h,
                              label: '${h.toString().padLeft(2, '0')}:00',
                            )).toList(),
                            onSelected: (v) => setDialogState(() => lunchEndHour = v ?? 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Foto del aula
                  Text(
                    isSpanish ? 'Foto del aula' : 'Classroom photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSpanish 
                        ? 'Formato: JPG • Tamaño: 400x400px • Ratio: 1:1'
                        : 'Format: JPG • Size: 400x400px • Ratio: 1:1',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Preview de imagen
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: imagePreviewBytes != null
                                ? Image.memory(imagePreviewBytes!, fit: BoxFit.cover)
                                : (imageUrl != null && imageUrl!.isNotEmpty)
                                    ? Image.network(
                                        imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          LucideIcons.imageOff,
                                          size: 24,
                                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                        ),
                                      )
                                    : Icon(
                                        LucideIcons.image,
                                        size: 24,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                      ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedImage != null || (imageUrl != null && imageUrl!.isNotEmpty))
                                Text(
                                  selectedImage?.name ?? (isSpanish ? 'Imagen actual' : 'Current image'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              else
                                Text(
                                  isSpanish ? 'Sin imagen' : 'No image',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 400,
                                        maxHeight: 400,
                                        imageQuality: 85,
                                      );
                                      if (image != null) {
                                        final bytes = await image.readAsBytes();
                                        setDialogState(() {
                                          selectedImage = image;
                                          imagePreviewBytes = bytes;
                                        });
                                      }
                                    },
                                    icon: const Icon(LucideIcons.upload, size: 16),
                                    label: Text(
                                      isSpanish ? 'Seleccionar' : 'Select',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                  if (selectedImage != null || (imageUrl != null && imageUrl!.isNotEmpty)) ...[
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          selectedImage = null;
                                          imagePreviewBytes = null;
                                          imageUrl = null;
                                        });
                                      },
                                      child: Text(
                                        isSpanish ? 'Quitar' : 'Remove',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ubicación GPS con mapa interactivo
                  Text(
                    isSpanish ? 'Ubicación en mapa' : 'Map location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSpanish 
                        ? 'Haz clic en el mapa para seleccionar la ubicación exacta del aula'
                        : 'Click on the map to select the exact classroom location',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Mini mapa de preview
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: latitude != null && longitude != null
                                ? MapPreviewWidget(
                                    latitude: latitude!,
                                    longitude: longitude!,
                                    height: 150,
                                  )
                                : Container(
                                    color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            LucideIcons.map,
                                            size: 32,
                                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            isSpanish ? 'Sin ubicación' : 'No location',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Botones de acción
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                          ),
                          child: Row(
                            children: [
                              if (latitude != null && longitude != null) ...[
                                Icon(LucideIcons.mapPin, size: 14, color: AppColors.success),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: isDark ? AppColors.darkText : AppColors.lightText,
                                    ),
                                  ),
                                ),
                              ] else
                                Expanded(
                                  child: Text(
                                    isSpanish ? 'Selecciona una ubicación' : 'Select a location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // Abrir selector de mapa interactivo
                                  final result = await MapPickerWidget.show(
                                    context: context,
                                    initialLatitude: latitude,
                                    initialLongitude: longitude,
                                  );
                                  if (result != null) {
                                    setDialogState(() {
                                      latitude = result['latitude'];
                                      longitude = result['longitude'];
                                    });
                                  }
                                },
                                icon: Icon(
                                  latitude != null ? LucideIcons.pencil : LucideIcons.mapPin,
                                  size: 14,
                                ),
                                label: Text(
                                  latitude != null 
                                      ? (isSpanish ? 'Cambiar' : 'Change')
                                      : (isSpanish ? 'Seleccionar' : 'Select'),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              if (latitude != null) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      latitude = null;
                                      longitude = null;
                                    });
                                  },
                                  child: Text(
                                    isSpanish ? 'Quitar' : 'Remove',
                                    style: TextStyle(fontSize: 12, color: AppColors.error),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextField(
                    controller: descriptionCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Descripción (opcional)' : 'Description (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      alignLabelWithHint: true,
                    ),
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
                if (nameCtrl.text.isNotEmpty && 
                    locationCtrl.text.isNotEmpty && 
                    capacityCtrl.text.isNotEmpty &&
                    selectedDays.isNotEmpty) {
                  Navigator.pop(ctx, {
                    'name': nameCtrl.text,
                    'location': locationCtrl.text,
                    'capacity': int.tryParse(capacityCtrl.text) ?? 10,
                    'schedule': '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00',
                    'lunchBreak': hasLunchBreak 
                        ? '${lunchStartHour.toString().padLeft(2, '0')}:00 - ${lunchEndHour.toString().padLeft(2, '0')}:00'
                        : null,
                    'availableDays': selectedDays,
                    'imageUrl': imageUrl,
                    'selectedImage': selectedImage,
                    'latitude': latitude,
                    'longitude': longitude,
                    'description': descriptionCtrl.text.isNotEmpty ? descriptionCtrl.text : null,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(aula == null 
                  ? (isSpanish ? 'Crear' : 'Create')
                  : (isSpanish ? 'Guardar' : 'Save')),
            ),
          ],
        ),
      ),
    );
  }
}
