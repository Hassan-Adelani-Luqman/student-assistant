/// Dashboard-specific widgets separated for better code organization
///
/// This file contains custom widgets used in the dashboard screen,
/// separated from the main dashboard screen for better maintainability.
library;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// A statistical card widget that displays a numeric value with a label
///
/// Used in the dashboard to show metrics like active projects count,
/// today's sessions, and attendance rate. Supports optional tap actions
/// and custom colors for different states (e.g., attendance color coding).
class StatisticCard extends StatelessWidget {
  /// The main numeric value to display
  final String value;

  /// The label describing what the value represents
  final String label;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  /// Optional custom color for the value and border
  final Color? accentColor;

  const StatisticCard({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: UIConstants.defaultAnimationDurationMs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.darkBlue,
            borderRadius: BorderRadius.circular(
              UIConstants.defaultBorderRadius,
            ),
            border: accentColor != null
                ? Border.all(
                    color: accentColor!.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: (accentColor ?? AppTheme.accentYellow).withValues(
                  alpha: 0.1,
                ),
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
                  color: accentColor ?? AppTheme.textLight,
                ),
              ),
              SizedBox(height: UIConstants.smallSpacing),
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
}

/// Attendance warning banner widget shown when attendance is below threshold
///
/// This widget displays a prominent warning when a student's attendance
/// percentage falls below the minimum required (75%). Tapping the banner
/// navigates to the attendance details screen.
class AttendanceWarningBanner extends StatelessWidget {
  /// The current attendance percentage to display
  final double attendancePercentage;

  /// Callback when the banner is tapped (usually navigates to attendance screen)
  final VoidCallback onTap;

  const AttendanceWarningBanner({
    super.key,
    required this.attendancePercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(UIConstants.defaultScreenPadding),
        decoration: BoxDecoration(
          color: AppTheme.warningRed,
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.textLight,
              size: 32,
            ),
            SizedBox(width: UIConstants.defaultSpacing),
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
                    'Your attendance is ${attendancePercentage.toStringAsFixed(1)}% - Tap to view details',
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
  }
}

/// Course selector dropdown widget
///
/// Displays a dropdown menu for selecting courses to filter dashboard data.
/// Uses the app's dark theme colors and handles course selection changes.
class CourseSelector extends StatelessWidget {
  /// Currently selected course
  final String selectedCourse;

  /// List of available courses to choose from
  final List<String> courses;

  /// Callback when a new course is selected
  final ValueChanged<String?> onChanged;

  const CourseSelector({
    super.key,
    required this.selectedCourse,
    required this.courses,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(UIConstants.defaultScreenPadding),
      padding: EdgeInsets.symmetric(
        horizontal: UIConstants.defaultScreenPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedCourse,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppTheme.darkBlue,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textLight),
        style: const TextStyle(
          color: AppTheme.textLight,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        items: courses.map((course) {
          return DropdownMenuItem<String>(value: course, child: Text(course));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

/// Today's item widget - represents a single class or assignment for today
///
/// Used in the "Today's Classes" section to display sessions and assignments
/// scheduled for the current day.
class TodayItem extends StatelessWidget {
  /// The title of the item (class name or assignment title)
  final String title;

  /// The subtitle (session type or due date)
  final String subtitle;

  /// Optional additional due date text
  final String? dueDate;

  const TodayItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UIConstants.defaultScreenPadding,
        vertical: 16,
      ),
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
                    dueDate!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
///
/// A reusable header used to label different sections in the dashboard
/// and other screens.
class SectionHeader extends StatelessWidget {
  /// The text to display in the header
  final String title;

  /// Optional trailing widget (e.g., a button or icon)
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(UIConstants.defaultScreenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
