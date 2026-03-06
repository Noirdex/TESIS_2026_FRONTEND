import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../providers/locale_provider.dart';

/// Widget para seleccionar una ubicacion en un mapa interactivo
class MapPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final double initialZoom;
  final Function(double latitude, double longitude)? onLocationSelected;
  final bool readOnly;
  
  const MapPickerWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 15.0,
    this.onLocationSelected,
    this.readOnly = false,
  });
  
  /// Muestra el selector de mapa en un dialogo y retorna las coordenadas
  static Future<Map<String, double>?> show({
    required BuildContext context,
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    
    double? selectedLat = initialLatitude;
    double? selectedLng = initialLongitude;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 600,
            height: 500,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.mapPin, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isSpanish ? 'Seleccionar Ubicacion' : 'Select Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isSpanish 
                      ? 'Haz clic en el mapa para colocar el marcador'
                      : 'Click on the map to place the marker',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Mapa
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MapPickerWidget(
                      initialLatitude: initialLatitude,
                      initialLongitude: initialLongitude,
                      onLocationSelected: (lat, lng) {
                        setDialogState(() {
                          selectedLat = lat;
                          selectedLng = lng;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Coordenadas seleccionadas
                if (selectedLat != null && selectedLng != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.navigation, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedLat!.toStringAsFixed(6)}, ${selectedLng!.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: selectedLat != null && selectedLng != null
                          ? () => Navigator.pop(ctx, true)
                          : null,
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: Text(isSpanish ? 'Confirmar' : 'Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    if (result == true && selectedLat != null && selectedLng != null) {
      return {'latitude': selectedLat!, 'longitude': selectedLng!};
    }
    return null;
  }
  
  @override
  State<MapPickerWidget> createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget> {
  late final MapController _mapController;
  LatLng? _selectedLocation;
  
  // Centro por defecto: Cuenca, Ecuador
  static const _defaultLat = -2.9001;
  static const _defaultLng = -79.0059;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }
  
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
  
  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (widget.readOnly) return;
    
    setState(() {
      _selectedLocation = point;
    });
    
    widget.onLocationSelected?.call(point.latitude, point.longitude);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    final initialCenter = _selectedLocation ?? 
        LatLng(widget.initialLatitude ?? _defaultLat, widget.initialLongitude ?? _defaultLng);
    
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: widget.initialZoom,
            onTap: _handleTap,
            interactionOptions: InteractionOptions(
              flags: widget.readOnly 
                  ? InteractiveFlag.none 
                  : InteractiveFlag.all,
            ),
          ),
          children: [
            // Capa de tiles (OpenStreetMap)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.software_agendamiento',
            ),
            
            // Marcador de ubicacion seleccionada
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(
                      LucideIcons.mapPin,
                      color: AppColors.ucRed,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),
        
        // Controles de zoom
        if (!widget.readOnly)
          Positioned(
            right: 8,
            bottom: 8,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: LucideIcons.plus,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 4),
                _buildZoomButton(
                  icon: LucideIcons.minus,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        
        // Boton para centrar en ubicacion actual
        if (!widget.readOnly)
          Positioned(
            right: 8,
            top: 8,
            child: _buildZoomButton(
              icon: LucideIcons.locate,
              onPressed: () {
                // Centrar en ubicacion por defecto (Cuenca)
                _mapController.move(
                  LatLng(_defaultLat, _defaultLng),
                  widget.initialZoom,
                );
              },
              isDark: isDark,
            ),
          ),
      ],
    );
  }
  
  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: isDark ? AppColors.darkText : AppColors.lightText,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Widget compacto para mostrar ubicacion en modo solo lectura
class MapPreviewWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;
  final VoidCallback? onTap;
  
  const MapPreviewWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 150,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightBorder,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(latitude, longitude),
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.software_agendamiento',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(latitude, longitude),
                        width: 30,
                        height: 30,
                        child: Icon(
                          LucideIcons.mapPin,
                          color: AppColors.ucRed,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onTap != null)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.externalLink, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Ver mapa',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
