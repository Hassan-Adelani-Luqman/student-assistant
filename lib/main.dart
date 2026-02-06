import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/assignment_provider.dart';
import 'providers/session_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/schedule_screen.dart';
import 'widgets/attendance_badge.dart';

/// Main entry point of the Student Academic Platform application
///
/// This app helps ALU students manage their academic responsibilities,
/// track assignments, monitor schedules, and maintain attendance records.
void main() {
  runApp(const StudentAssistantApp());
}

/// Root widget that sets up providers and theme
class StudentAssistantApp extends StatelessWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider allows multiple providers to be available throughout the app
    return MultiProvider(
      providers: [
        // Assignment provider for managing assignments
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),

        // Session provider for managing academic sessions
        ChangeNotifierProvider(create: (_) => SessionProvider()),

        // Attendance provider depends on session provider
        ChangeNotifierProxyProvider<SessionProvider, AttendanceProvider>(
          create: (context) => AttendanceProvider(
            Provider.of<SessionProvider>(context, listen: false),
          ),
          update: (context, sessionProvider, previous) =>
              previous ?? AttendanceProvider(sessionProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Student Academic Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}

/// Main navigation screen with bottom navigation bar
///
/// Provides navigation between three main sections:
/// - Dashboard: Overview of academic status
/// - Assignments: Assignment management
/// - Schedule: Session and calendar management
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // List of screens corresponding to bottom navigation items
  final List<Widget> _screens = const [
    DashboardScreen(),
    AssignmentsScreen(),
    ScheduleScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
          // Floating attendance badge when at risk
          const AttendanceBadge(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
