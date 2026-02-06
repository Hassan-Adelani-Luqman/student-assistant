/// Model class for tracking attendance statistics
///
/// This class calculates and maintains attendance percentage and
/// determines if a student is at risk (below 75% attendance)
class AttendanceRecord {
  final int totalSessions;
  final int attendedSessions;

  AttendanceRecord({
    required this.totalSessions,
    required this.attendedSessions,
  });

  /// Calculates the attendance percentage
  /// Returns 0 if no sessions have been recorded
  double get percentage {
    if (totalSessions == 0) return 0.0;
    return (attendedSessions / totalSessions) * 100;
  }

  /// Checks if attendance is below the 75% threshold (at risk)
  bool get isAtRisk => percentage < 75;

  /// Returns the number of sessions missed
  int get missedSessions => totalSessions - attendedSessions;

  /// Formats percentage as a string with one decimal place
  String get formattedPercentage {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Determines the attendance status color based on percentage
  /// Green (>= 85%), Yellow (75-84%), Red (< 75%)
  String get statusLevel {
    if (percentage >= 85) return 'excellent';
    if (percentage >= 75) return 'good';
    return 'at-risk';
  }

  @override
  String toString() {
    return 'AttendanceRecord(total: $totalSessions, attended: $attendedSessions, percentage: $formattedPercentage)';
  }
}
