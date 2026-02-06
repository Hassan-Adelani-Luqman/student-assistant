import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assignment_provider.dart';
import '../providers/session_provider.dart';
import '../providers/attendance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ui_helpers.dart';
import '../utils/constants.dart';
import '../utils/business_logic_helpers.dart';
import 'attendance_screen.dart';

/// Dashboard screen - Main overview of student's academic status
///
/// This widget displays the main dashboard with:
/// - Course selector dropdown for filtering by course
/// - Attendance warning card (shown when attendance is below 75%)
/// - Statistics cards showing active projects, today's sessions, and attendance rate
/// - Today's classes and assignments due
///
/// The screen uses [DashboardBusinessLogic] for all calculations and business rules,
/// keeping the UI code separate from business logic.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Currently selected course for filtering
  String _selectedCourse = CourseConstants.defaultCourse;

  /// Available courses for the dropdown selector
  final List<String> _courses = CourseConstants.availableCourses;

  @override
  void initState() {
    super.initState();
    // Load data after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Loads assignments and sessions from storage
  Future<void> _loadData() async {
    if (!mounted) return;

    final assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );

    // Set up error callbacks
    assignmentProvider.setErrorCallback((error) {
      if (mounted) {
        showErrorSnackBar(context, error);
      }
    });

    sessionProvider.setErrorCallback((error) {
      if (mounted) {
        showErrorSnackBar(context, error);
      }
    });

    // Load data
    await Future.wait([
      assignmentProvider.loadAssignments(),
      sessionProvider.loadSessions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentYellow,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with gradient
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.navyBlue,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.navyBlue, AppTheme.darkBlue],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Today's Date and Academic Week
                  _buildDateAndWeek(),
                  const SizedBox(height: 16),

                  // Course Selector
                  _buildCourseSelector(),

                  // Attendance Warning (if applicable)
                  _buildAttendanceWarning(),
                  const SizedBox(height: 4),

                  // Statistics Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatsCards(),
                  ),
                  const SizedBox(height: 24),

                  // Today's Classes and Assignments
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTodaysSection(),
                  ),
                  const SizedBox(height: 24),

                  // Upcoming Assignments (Next 7 Days)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildUpcomingAssignmentsSection(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the date and academic week display
  Widget _buildDateAndWeek() {
    final now = DateTime.now();
    final weekNumber = _getAcademicWeekNumber(now);
    final formattedDate = _formatFullDate(now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkBlue, AppTheme.navyBlue],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  now.day.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  _getMonthAbbr(now.month),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.accentYellow,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Academic Week $weekNumber',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the course selector dropdown
  Widget _buildCourseSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedCourse,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppTheme.darkBlue,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textLight),
        style: const TextStyle(
          color: AppTheme.textLight,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        items: _courses.map((course) {
          return DropdownMenuItem<String>(value: course, child: Text(course));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCourse = value;
            });
          }
        },
      ),
    );
  }

  /// Builds attendance warning card if attendance is below 75%
  Widget _buildAttendanceWarning() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        if (!attendanceProvider.shouldShowWarning) {
          return const SizedBox.shrink();
        }

        final percentage = attendanceProvider.attendancePercentage;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendanceScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.textLight,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ATTENDANCE AT RISK',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your attendance is ${percentage.toStringAsFixed(1)}% - Tap to view details',
                        style: TextStyle(
                          color: AppTheme.textLight.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textLight),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the statistics cards row
  Widget _buildStatsCards() {
    return Consumer3<AssignmentProvider, SessionProvider, AttendanceProvider>(
      builder:
          (
            context,
            assignmentProvider,
            sessionProvider,
            attendanceProvider,
            child,
          ) {
            final pendingAssignments = assignmentProvider.pendingCount;
            final todaysSessions = sessionProvider.todaysSessions.length;
            final attendancePercentage =
                attendanceProvider.attendancePercentage;

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '$pendingAssignments',
                    'Active\nProjects',
                    null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '$todaysSessions',
                    'Today\'s\nSessions',
                    null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '${attendancePercentage.toStringAsFixed(0)}%',
                    'Attendance\nRate',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AttendanceScreen(),
                        ),
                      );
                    },
                    color: AppTheme.getAttendanceColor(attendancePercentage),
                  ),
                ),
              ],
            );
          },
    );
  }

  /// Builds a single statistic card
  Widget _buildStatCard(
    String value,
    String label,
    VoidCallback? onTap, {
    Color? color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.darkBlue,
            borderRadius: BorderRadius.circular(12),
            border: color != null
                ? Border.all(color: color.withValues(alpha: 0.5), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: (color ?? AppTheme.accentYellow).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color ?? AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGray,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds today's classes and assignments section
  Widget _buildTodaysSection() {
    return Consumer2<SessionProvider, AssignmentProvider>(
      builder: (context, sessionProvider, assignmentProvider, child) {
        final todaysSessions = sessionProvider.todaysSessions;
        final todaysAssignments = assignmentProvider.getUpcomingAssignments(
          days: 0,
        );

        // Combine sessions and assignments for today
        final hasTodayItems =
            todaysSessions.isNotEmpty || todaysAssignments.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Today\'s Classes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              if (!hasTodayItems)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    'No classes or assignments for today',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 14),
                  ),
                )
              else ...[
                // Today's sessions
                ...todaysSessions.map(
                  (session) =>
                      _buildTodayItem(session.title, session.sessionType, null),
                ),

                // Today's assignments due
                ...todaysAssignments.map(
                  (assignment) => _buildTodayItem(
                    assignment.title,
                    'Due ${_formatDate(assignment.dueDate)}',
                    null,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Builds a single item in today's section
  Widget _buildTodayItem(String title, String subtitle, String? dueDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
                if (dueDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    dueDate,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textGray, size: 24),
        ],
      ),
    );
  }

  /// Builds upcoming assignments section (next 7 days)
  Widget _buildUpcomingAssignmentsSection() {
    return Consumer<AssignmentProvider>(
      builder: (context, assignmentProvider, child) {
        final upcomingAssignments = assignmentProvider.getUpcomingAssignments(
          days: 7,
        );

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment,
                      color: AppTheme.accentYellow,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Upcoming Assignments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (upcomingAssignments.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    'No assignments due in the next 7 days',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 14),
                  ),
                )
              else
                ...upcomingAssignments.map(
                  (assignment) {
                    final daysUntilDue = assignment.dueDate
                        .difference(DateTime.now())
                        .inDays;
                    String dueText;
                    Color dueColor;

                    if (daysUntilDue == 0) {
                      dueText = 'Due Today';
                      dueColor = AppTheme.warningRed;
                    } else if (daysUntilDue == 1) {
                      dueText = 'Due Tomorrow';
                      dueColor = AppTheme.accentYellow;
                    } else {
                      dueText = 'Due in $daysUntilDue days';
                      dueColor = AppTheme.textGray;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Priority indicator
                          Container(
                            width: 4,
                            height: 50,
                            decoration: BoxDecoration(
                              color: assignment.priority == 'High'
                                  ? AppTheme.warningRed
                                  : assignment.priority == 'Medium'
                                      ? AppTheme.accentYellow
                                      : AppTheme.successGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assignment.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  assignment.courseName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    // Assignment type badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: assignment.assignmentType == 'Summative'
                                            ? AppTheme.warningRed.withValues(alpha: 0.1)
                                            : AppTheme.successGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        assignment.assignmentType,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: assignment.assignmentType == 'Summative'
                                              ? AppTheme.warningRed
                                              : AppTheme.successGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: dueColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dueText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: dueColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Formats a date to a readable string
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Formats a date to full format (e.g., "Monday, February 3, 2026")
  String _formatFullDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, $monthName ${date.day}, ${date.year}';
  }

  /// Gets month abbreviation
  String _getMonthAbbr(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  /// Calculates academic week number
  /// Assumes semester starts on first Monday of September
  int _getAcademicWeekNumber(DateTime date) {
    // Find the first Monday of September in the current academic year
    int year = date.month >= 9 ? date.year : date.year - 1;
    DateTime septemberFirst = DateTime(year, 9, 1);
    
    // Find first Monday
    int daysUntilMonday = (DateTime.monday - septemberFirst.weekday) % 7;
    DateTime semesterStart = septemberFirst.add(Duration(days: daysUntilMonday));
    
    // Calculate weeks since semester start
    int daysSinceStart = date.difference(semesterStart).inDays;
    int weekNumber = (daysSinceStart / 7).floor() + 1;
    
    // Keep it within reasonable range (1-15 for a typical semester)
    return weekNumber.clamp(1, 15);
  }
}
