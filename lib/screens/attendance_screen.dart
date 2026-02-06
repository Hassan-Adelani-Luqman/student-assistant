import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/session_provider.dart';
import '../models/attendance_record.dart';
import '../theme/app_theme.dart';

/// Attendance tracking screen - Detailed attendance statistics and history
///
/// Features:
/// - Overall attendance percentage with visual progress
/// - Course-specific attendance breakdown
/// - Weekly attendance trend
/// - Session type statistics
/// - Attendance history list
/// - Warning alerts for low attendance
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAttendanceInfo(context),
          ),
        ],
      ),
      body: Consumer2<AttendanceProvider, SessionProvider>(
        builder: (context, attendanceProvider, sessionProvider, child) {
          final currentAttendance = attendanceProvider.currentAttendance;
          final weeklyAttendance = attendanceProvider.weeklyAttendance;

          return RefreshIndicator(
            onRefresh: () async {
              await sessionProvider.loadSessions();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall attendance card with circular progress
                  _buildOverallAttendanceCard(currentAttendance),
                  const SizedBox(height: 16),

                  // Warning banner if at risk
                  if (attendanceProvider.shouldShowWarning)
                    _buildWarningBanner(currentAttendance),
                  if (attendanceProvider.shouldShowWarning)
                    const SizedBox(height: 16),

                  // Weekly attendance stats
                  _buildWeeklyAttendanceCard(weeklyAttendance),
                  const SizedBox(height: 16),

                  // Session type breakdown
                  _buildSessionTypeBreakdown(attendanceProvider),
                  const SizedBox(height: 16),

                  // Attendance history
                  _buildAttendanceHistory(sessionProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the overall attendance card with circular progress indicator
  Widget _buildOverallAttendanceCard(AttendanceRecord attendance) {
    final percentage = attendance.percentage;
    final statusColor = AppTheme.getAttendanceColor(percentage);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkBlue, AppTheme.navyBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 24),

          // Circular progress indicator
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 12,
                    backgroundColor: AppTheme.textGray.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attendance.statusLevel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Attended',
                attendance.attendedSessions.toString(),
                AppTheme.successGreen,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textGray.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                'Total',
                attendance.totalSessions.toString(),
                AppTheme.accentYellow,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textGray.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                'Missed',
                (attendance.totalSessions - attendance.attendedSessions)
                    .toString(),
                AppTheme.warningRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a small stat item
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
        ),
      ],
    );
  }

  /// Builds warning banner for low attendance
  Widget _buildWarningBanner(AttendanceRecord attendance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningRed, width: 2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warningRed,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Alert',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your attendance is below 75%. You need to attend more sessions to improve.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.warningRed.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds weekly attendance card
  Widget _buildWeeklyAttendanceCard(AttendanceRecord weeklyAttendance) {
    final percentage = weeklyAttendance.percentage;
    final statusColor = AppTheme.getAttendanceColor(percentage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: AppTheme.textGray.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 16),

          // Weekly stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeeklyStat(
                'Attended',
                weeklyAttendance.attendedSessions,
                AppTheme.successGreen,
              ),
              _buildWeeklyStat(
                'Missed',
                weeklyAttendance.totalSessions -
                    weeklyAttendance.attendedSessions,
                AppTheme.warningRed,
              ),
              _buildWeeklyStat(
                'Total',
                weeklyAttendance.totalSessions,
                AppTheme.textDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds weekly stat item
  Widget _buildWeeklyStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textGray),
        ),
      ],
    );
  }

  /// Builds session type breakdown
  Widget _buildSessionTypeBreakdown(AttendanceProvider attendanceProvider) {
    final sessionTypes = [
      'Class',
      'Mastery Session',
      'Study Group',
      'PSL Meeting',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance by Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),

          ...sessionTypes.map((type) {
            final attendance = attendanceProvider.getAttendanceByType(type);
            if (attendance.totalSessions == 0) {
              return const SizedBox.shrink();
            }

            final percentage = attendance.percentage;
            final statusColor = AppTheme.getAttendanceColor(percentage);
            final typeColor = AppTheme.getSessionTypeColor(type);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${attendance.attendedSessions}/${attendance.totalSessions}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: AppTheme.textGray.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds attendance history list
  Widget _buildAttendanceHistory(SessionProvider sessionProvider) {
    final allSessions = sessionProvider.sessions
        .where((s) => s.attended != null)
        .toList();

    // Sort by date descending (most recent first)
    allSessions.sort((a, b) => b.date.compareTo(a.date));

    if (allSessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.history, size: 60, color: AppTheme.textGray),
              const SizedBox(height: 16),
              const Text(
                'No attendance records yet',
                style: TextStyle(fontSize: 16, color: AppTheme.textGray),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Attendance History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allSessions.length > 10 ? 10 : allSessions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = allSessions[index];
              final sessionColor = AppTheme.getSessionTypeColor(
                session.sessionType,
              );
              final attended = session.attended ?? false;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: attended
                        ? AppTheme.successGreen.withValues(alpha: 0.2)
                        : AppTheme.warningRed.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    attended ? Icons.check : Icons.close,
                    color: attended
                        ? AppTheme.successGreen
                        : AppTheme.warningRed,
                    size: 20,
                  ),
                ),
                title: Text(
                  session.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                subtitle: Text(
                  '${session.sessionType} • ${session.date.month}/${session.date.day}/${session.date.year}',
                  style: TextStyle(fontSize: 12, color: sessionColor),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: attended
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.warningRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    attended ? 'Present' : 'Absent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: attended
                          ? AppTheme.successGreen
                          : AppTheme.warningRed,
                    ),
                  ),
                ),
              );
            },
          ),
          if (allSessions.length > 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Showing 10 most recent records',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Shows attendance information dialog
  void _showAttendanceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Guidelines'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Attendance Status Levels:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _InfoItem(
                color: AppTheme.successGreen,
                label: 'Excellent',
                description: '90% and above',
              ),
              SizedBox(height: 8),
              _InfoItem(
                color: AppTheme.accentYellow,
                label: 'Good',
                description: '75% - 89%',
              ),
              SizedBox(height: 8),
              _InfoItem(
                color: AppTheme.warningRed,
                label: 'At Risk',
                description: 'Below 75%',
              ),
              SizedBox(height: 16),
              Text(
                'Minimum Required Attendance:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Students must maintain at least 75% attendance to remain in good academic standing.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for info items
class _InfoItem extends StatelessWidget {
  final Color color;
  final String label;
  final String description;

  const _InfoItem({
    required this.color,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        Expanded(child: Text(description)),
      ],
    );
  }
}
