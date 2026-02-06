/// Business logic helpers for dashboard calculations and data processing
///
/// This file separates business logic from UI code to improve
/// code organization and testability.
library;

import '../models/assignment.dart';
import '../models/academic_session.dart';
import '../utils/constants.dart';

/// Helper class for dashboard-related business logic
class DashboardBusinessLogic {
  // Private constructor to prevent instantiation
  DashboardBusinessLogic._();

  /// Calculates the number of active (incomplete) assignments
  static int calculateActiveAssignmentCount(List<Assignment> assignments) {
    return assignments.where((assignment) => !assignment.isCompleted).length;
  }

  /// Calculates the number of completed assignments
  static int calculateCompletedAssignmentCount(List<Assignment> assignments) {
    return assignments.where((assignment) => assignment.isCompleted).length;
  }

  /// Calculates completion percentage for assignments
  /// Returns 0 if no assignments exist
  static double calculateCompletionPercentage(List<Assignment> assignments) {
    if (assignments.isEmpty) return 0.0;

    final completed = calculateCompletedAssignmentCount(assignments);
    return (completed / assignments.length) * 100;
  }

  /// Gets assignments due today
  static List<Assignment> getAssignmentsDueToday(List<Assignment> assignments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return assignments.where((assignment) {
      final dueDate = DateTime(
        assignment.dueDate.year,
        assignment.dueDate.month,
        assignment.dueDate.day,
      );
      return dueDate.isAtSameMomentAs(today) && !assignment.isCompleted;
    }).toList();
  }

  /// Gets upcoming assignments (within next 7 days)
  static List<Assignment> getUpcomingAssignments(List<Assignment> assignments) {
    final now = DateTime.now();
    final weekFromNow = now.add(
      Duration(days: DateTimeConstants.upcomingDaysWindow),
    );

    return assignments.where((assignment) {
      return !assignment.isCompleted &&
          assignment.dueDate.isAfter(now) &&
          assignment.dueDate.isBefore(weekFromNow);
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Gets overdue assignments
  static List<Assignment> getOverdueAssignments(List<Assignment> assignments) {
    final now = DateTime.now();

    return assignments.where((assignment) {
      return !assignment.isCompleted && assignment.dueDate.isBefore(now);
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Gets sessions scheduled for today
  static List<AcademicSession> getSessionsForToday(
    List<AcademicSession> sessions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return sessions.where((session) {
      final sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      return sessionDate.isAtSameMomentAs(today);
    }).toList()..sort((a, b) {
      // Sort by start time
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  /// Counts total sessions attended
  static int countAttendedSessions(List<AcademicSession> sessions) {
    return sessions.where((session) => session.attended == true).length;
  }

  /// Counts total sessions with recorded attendance
  static int countSessionsWithRecordedAttendance(
    List<AcademicSession> sessions,
  ) {
    return sessions.where((session) => session.attended != null).length;
  }

  /// Calculates attendance percentage
  /// Returns 0 if no sessions have recorded attendance
  static double calculateAttendancePercentage(List<AcademicSession> sessions) {
    final recordedSessions = countSessionsWithRecordedAttendance(sessions);
    if (recordedSessions == 0) return 0.0;

    final attended = countAttendedSessions(sessions);
    return (attended / recordedSessions) * 100;
  }

  /// Determines if attendance warning should be shown
  /// Warning is shown when attendance is below 75%
  static bool shouldShowAttendanceWarning(double attendancePercentage) {
    return attendancePercentage < AttendanceConstants.warningThreshold &&
        attendancePercentage > 0;
  }

  /// Gets attendance status color indicator
  /// - Green: >= 80% (good)
  /// - Yellow: 75-79% (warning)
  /// - Red: < 75% (critical)
  static AttendanceStatus getAttendanceStatus(double percentage) {
    if (percentage >= AttendanceConstants.goodAttendanceThreshold) {
      return AttendanceStatus.good;
    } else if (percentage >= AttendanceConstants.warningThreshold) {
      return AttendanceStatus.warning;
    } else {
      return AttendanceStatus.critical;
    }
  }

  /// Formats due date for display
  /// Returns:
  /// - "Overdue" if past due
  /// - "Due Today" if due today
  /// - "Due Tomorrow" if due tomorrow
  /// - "Due in X days" otherwise
  static String formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final difference = due.difference(today).inDays;

    if (difference < 0) {
      final daysOverdue = difference.abs();
      return daysOverdue == 1 ? '1 day overdue' : '$daysOverdue days overdue';
    } else if (difference == 0) {
      return 'Due Today';
    } else if (difference == 1) {
      return 'Due Tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }

  /// Determines assignment urgency level
  /// - Critical: Overdue
  /// - High: Due today or tomorrow
  /// - Medium: Due within 3 days
  /// - Low: Due later
  static AssignmentUrgency getAssignmentUrgency(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final daysUntilDue = due.difference(today).inDays;

    if (daysUntilDue < 0) {
      return AssignmentUrgency.critical; // Overdue
    } else if (daysUntilDue <= DateTimeConstants.dueVerySoonDaysThreshold) {
      return AssignmentUrgency.high; // Due today or tomorrow
    } else if (daysUntilDue <= DateTimeConstants.dueSoonDaysThreshold) {
      return AssignmentUrgency.medium; // Due within 3 days
    } else {
      return AssignmentUrgency.low; // Due later
    }
  }
}

/// Attendance status enum
enum AttendanceStatus {
  good, // >= 80%
  warning, // 75-79%
  critical, // < 75%
}

/// Assignment urgency enum
enum AssignmentUrgency {
  critical, // Overdue
  high, // Due very soon (0-1 days)
  medium, // Due soon (2-3 days)
  low, // Due later (> 3 days)
}

/// Helper class for filtering and sorting logic
class DataFilteringLogic {
  // Private constructor to prevent instantiation
  DataFilteringLogic._();

  /// Filters assignments by course
  /// Returns all assignments if course is "All Selected Courses"
  static List<Assignment> filterAssignmentsByCourse(
    List<Assignment> assignments,
    String selectedCourse,
  ) {
    if (selectedCourse == CourseConstants.defaultCourse) {
      return assignments;
    }

    return assignments
        .where((assignment) => assignment.courseName == selectedCourse)
        .toList();
  }

  /// Filters sessions by type
  /// Returns all sessions if type is "All"
  static List<AcademicSession> filterSessionsByType(
    List<AcademicSession> sessions,
    String selectedType,
  ) {
    if (selectedType == SessionTypeConstants.defaultSessionType) {
      return sessions;
    }

    return sessions
        .where((session) => session.sessionType == selectedType)
        .toList();
  }

  /// Filters assignments by priority/type
  /// - "All": All assignments
  /// - "Formative": Low/Medium priority (not high)
  /// - "Summative": High priority
  static List<Assignment> filterAssignmentsByType(
    List<Assignment> assignments,
    String filterType,
  ) {
    switch (filterType.toLowerCase()) {
      case 'formative':
        return assignments
            .where((a) => a.priority.toLowerCase() != 'high')
            .toList();
      case 'summative':
        return assignments
            .where((a) => a.priority.toLowerCase() == 'high')
            .toList();
      default:
        return assignments;
    }
  }

  /// Sorts assignments by due date (ascending)
  static List<Assignment> sortAssignmentsByDueDate(
    List<Assignment> assignments,
  ) {
    final sorted = List<Assignment>.from(assignments);
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }

  /// Sorts sessions by date and time (ascending)
  static List<AcademicSession> sortSessionsByDateTime(
    List<AcademicSession> sessions,
  ) {
    final sorted = List<AcademicSession>.from(sessions);
    sorted.sort((a, b) {
      // First compare dates
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;

      // If dates are equal, compare start times
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return sorted;
  }
}
