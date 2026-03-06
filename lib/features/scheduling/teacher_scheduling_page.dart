import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../shared/dashboard_layout.dart';
import 'widgets/schedule_view.dart';
import 'widgets/bookings_view.dart';
import 'widgets/profile_view.dart';
import 'widgets/training_requests_view.dart';

/// Página principal de agendamiento para docentes
class TeacherSchedulingPage extends StatefulWidget {
  const TeacherSchedulingPage({super.key});

  @override
  State<TeacherSchedulingPage> createState() => _TeacherSchedulingPageState();
}

class _TeacherSchedulingPageState extends State<TeacherSchedulingPage> {
  DashboardView _currentView = DashboardView.schedule;

  String _getPageTitle(AppStrings t) {
    switch (_currentView) {
      case DashboardView.schedule:
        return 'Agendar Aula';
      case DashboardView.bookings:
        return 'Mis Agendas';
      case DashboardView.profile:
        return 'Mi Perfil';
      case DashboardView.training:
        return 'Capacitaciones';
      default:
        return 'Dashboard';
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
      isAdmin: false,
      child: _buildContent(t),
    );
  }

  Widget _buildContent(AppStrings t) {
    switch (_currentView) {
      case DashboardView.schedule:
        return const ScheduleView(isAdmin: false);
      case DashboardView.bookings:
        return const BookingsView(isAdmin: false);
      case DashboardView.profile:
        return const ProfileView(isAdmin: false);
      case DashboardView.training:
        return const TrainingRequestsView(isAdmin: false); // Solo lectura para docentes
      default:
        return const ScheduleView(isAdmin: false);
    }
  }
}
