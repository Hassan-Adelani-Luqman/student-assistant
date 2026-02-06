import 'package:flutter/foundation.dart';
import '../models/attendance_record.dart';
import 'session_provider.dart';

/// Provider class for managing attendance tracking
///
/// This class calculates attendance statistics based on recorded sessions
/// and provides real-time attendance metrics
class AttendanceProvider with ChangeNotifier {
  final SessionProvider _sessionProvider;

  AttendanceProvider(this._sessionProvider) {
    // Listen to session changes to update attendance automatically
    _sessionProvider.addListener(_onSessionsChanged);
  }

  /// Called when sessions are modified
  void _onSessionsChanged() {
    notifyListeners();
  }

  /// Calculates current attendance record based on all sessions
  AttendanceRecord get currentAttendance {
    final sessions = _sessionProvider.sessions;

    // Only count sessions where attendance has been recorded
    final recordedSessions = sessions.where((s) => s.attended != null).toList();
    final attendedSessions = recordedSessions
        .where((s) => s.attended == true)
        .length;

    return AttendanceRecord(
      totalSessions: recordedSessions.length,
      attendedSessions: attendedSessions,
    );
  }

  /// Checks if attendance warning should be displayed
  bool get shouldShowWarning {
    return currentAttendance.isAtRisk && currentAttendance.totalSessions > 0;
  }

  /// Returns attendance percentage as a double
  double get attendancePercentage {
    return currentAttendance.percentage;
  }

  /// Returns formatted attendance percentage string
  String get formattedPercentage {
    return currentAttendance.formattedPercentage;
  }

  /// Returns the attendance status level (excellent, good, at-risk)
  String get statusLevel {
    return currentAttendance.statusLevel;
  }

  /// Calculates attendance for a specific session type
  AttendanceRecord getAttendanceByType(String sessionType) {
    final sessions = _sessionProvider.sessions
        .where((s) => s.sessionType == sessionType)
        .toList();

    final recordedSessions = sessions.where((s) => s.attended != null).toList();
    final attendedSessions = recordedSessions
        .where((s) => s.attended == true)
        .length;

    return AttendanceRecord(
      totalSessions: recordedSessions.length,
      attendedSessions: attendedSessions,
    );
  }

  /// Calculates attendance for the current week
  AttendanceRecord get weeklyAttendance {
    final sessions = _sessionProvider.weeklySessions;

    final recordedSessions = sessions.where((s) => s.attended != null).toList();
    final attendedSessions = recordedSessions
        .where((s) => s.attended == true)
        .length;

    return AttendanceRecord(
      totalSessions: recordedSessions.length,
      attendedSessions: attendedSessions,
    );
  }

  @override
  void dispose() {
    _sessionProvider.removeListener(_onSessionsChanged);
    super.dispose();
  }
}
