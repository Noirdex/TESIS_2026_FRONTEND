import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../admin/landing_editor_view.dart';
import '../shared/dashboard_layout.dart';
import 'widgets/admin_block_schedule_view.dart';
import 'widgets/aulas_management_view.dart';
import 'widgets/bookings_view.dart';
import 'widgets/profile_view.dart';
import 'widgets/training_requests_view.dart';

/// Página principal de agendamiento para administradores
/// El admin NO agenda clases, solo bloquea horarios como "No Disponible"
class AdminSchedulingPage extends StatefulWidget {
  const AdminSchedulingPage({super.key});

  @override
  State<AdminSchedulingPage> createState() => _AdminSchedulingPageState();
}

class _AdminSchedulingPageState extends State<AdminSchedulingPage> {
  DashboardView _currentView = DashboardView.bookings;

  String _getPageTitle(AppStrings t) {
    switch (_currentView) {
      case DashboardView.schedule:
        return 'Bloquear Horarios';
      case DashboardView.bookings:
        return 'Gestión de Reservas';
      case DashboardView.profile:
        return 'Mi Perfil';
      case DashboardView.content:
        return 'Editor Landing Page';
      case DashboardView.training:
        return 'Solicitudes de Capacitación';
      case DashboardView.classrooms:
        return 'Gestión de Aulas';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().languageCode;
    final t = AppTranslations.of(lang);

    return DashboardLayout(
      pageTitle: _getPageTitle(t),
      currentView: _currentView,
      onViewChange: (view) => setState(() => _currentView = view),
      isAdmin: true,
      child: _buildContent(t),
    );
  }

  Widget _buildContent(AppStrings t) {
    switch (_currentView) {
      case DashboardView.schedule:
        // Admin solo bloquea horarios, NO agenda clases
        return const AdminBlockScheduleView();
      case DashboardView.bookings:
        return const BookingsView(isAdmin: true);
      case DashboardView.profile:
        return const ProfileView(isAdmin: true);
      case DashboardView.content:
        return const LandingEditorView();
      case DashboardView.training:
        return const TrainingRequestsView(isAdmin: true);
      case DashboardView.classrooms:
        return const AulasManagementView();
    }
  }

  
}
