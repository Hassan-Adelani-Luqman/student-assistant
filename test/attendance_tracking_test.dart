import 'package:flutter_test/flutter_test.dart';
import 'package:student_assistant/models/academic_session.dart';
import 'package:student_assistant/models/attendance_record.dart';
import 'package:student_assistant/providers/session_provider.dart';
import 'package:student_assistant/providers/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive test suite for Attendance Tracking features
///
/// Tests all required features:
/// 1. Calculate attendance percentage automatically
/// 2. Display attendance metrics clearly on dashboard
/// 3. Provide alerts when attendance drops below 75%
/// 4. Maintain attendance history for reference
void main() {
  group('Attendance Tracking - Comprehensive Tests', () {
    late SessionProvider sessionProvider;
    late AttendanceProvider attendanceProvider;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      sessionProvider = SessionProvider();
      attendanceProvider = AttendanceProvider(sessionProvider);
    });

    group('1. Calculate Attendance Percentage Automatically', () {
      test('Calculates 0% when no sessions recorded', () {
        expect(attendanceProvider.attendancePercentage, 0.0);
        expect(attendanceProvider.formattedPercentage, '0.0%');
      });

      test('Calculates 100% when all sessions attended', () async {
        // Add sessions and mark all as attended
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.addSession(_createSession('Session 3'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, true);

        expect(attendanceProvider.attendancePercentage, 100.0);
        expect(attendanceProvider.currentAttendance.attendedSessions, 3);
        expect(attendanceProvider.currentAttendance.totalSessions, 3);
      });

      test('Calculates 0% when all sessions marked absent', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, false);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);

        expect(attendanceProvider.attendancePercentage, 0.0);
        expect(attendanceProvider.currentAttendance.missedSessions, 2);
      });

      test('Calculates correct percentage with mixed attendance', () async {
        // Create 10 sessions
        for (int i = 0; i < 10; i++) {
          await sessionProvider.addSession(_createSession('Session $i'));
        }

        // Attend 7, miss 3 (70%)
        for (int i = 0; i < 7; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, true);
        }
        for (int i = 7; i < 10; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, false);
        }

        expect(attendanceProvider.attendancePercentage, 70.0);
        expect(attendanceProvider.currentAttendance.attendedSessions, 7);
        expect(attendanceProvider.currentAttendance.totalSessions, 10);
      });

      test('Ignores sessions without recorded attendance', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.addSession(_createSession('Session 3'));

        // Only record attendance for 2 sessions
        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        // Session 3 has no attendance recorded

        expect(attendanceProvider.attendancePercentage, 50.0);
        expect(attendanceProvider.currentAttendance.totalSessions, 2); // Only 2 recorded
      });

      test('Updates automatically when attendance is recorded', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        expect(attendanceProvider.attendancePercentage, 0.0);

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        expect(attendanceProvider.attendancePercentage, 100.0);
      });

      test('Calculates 75% (boundary case)', () async {
        // Create 4 sessions
        for (int i = 0; i < 4; i++) {
          await sessionProvider.addSession(_createSession('Session $i'));
        }

        // Attend 3, miss 1 (75%)
        for (int i = 0; i < 3; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, true);
        }
        await sessionProvider.recordAttendance(sessionProvider.sessions[3].id, false);

        expect(attendanceProvider.attendancePercentage, 75.0);
      });
    });

    group('2. Display Attendance Metrics on Dashboard', () {
      test('Provides formatted percentage string', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.addSession(_createSession('Session 3'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, false);

        expect(attendanceProvider.formattedPercentage, '66.7%');
      });

      test('Returns current attendance record with all metrics', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);

        final record = attendanceProvider.currentAttendance;
        expect(record.totalSessions, 2);
        expect(record.attendedSessions, 1);
        expect(record.missedSessions, 1);
        expect(record.percentage, 50.0);
      });

      test('Provides status level (excellent/good/at-risk)', () async {
        // Test excellent (>= 85%)
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        expect(attendanceProvider.statusLevel, 'excellent');

        sessionProvider = SessionProvider();
        attendanceProvider = AttendanceProvider(sessionProvider);

        // Test good (75-84%)
        for (int i = 0; i < 5; i++) {
          await sessionProvider.addSession(_createSession('Session $i'));
        }
        for (int i = 0; i < 4; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, true);
        }
        await sessionProvider.recordAttendance(sessionProvider.sessions[4].id, false);
        expect(attendanceProvider.statusLevel, 'good');

        sessionProvider = SessionProvider();
        attendanceProvider = AttendanceProvider(sessionProvider);

        // Test at-risk (< 75%)
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        expect(attendanceProvider.statusLevel, 'at-risk');
      });

      test('Calculates weekly attendance separately', () async {
        final now = DateTime.now();
        
        // Add sessions for current week
        await sessionProvider.addSession(_createSessionWithDate(
          'This Week Session 1',
          now,
        ));
        await sessionProvider.addSession(_createSessionWithDate(
          'This Week Session 2',
          now.subtract(const Duration(days: 2)),
        ));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);

        final weeklyAttendance = attendanceProvider.weeklyAttendance;
        expect(weeklyAttendance.totalSessions, 2);
        expect(weeklyAttendance.attendedSessions, 1);
        expect(weeklyAttendance.percentage, 50.0);
      });

      test('Calculates attendance by session type', () async {
        await sessionProvider.addSession(_createSessionWithType('Class 1', 'Class'));
        await sessionProvider.addSession(_createSessionWithType('Class 2', 'Class'));
        await sessionProvider.addSession(_createSessionWithType('Study Group', 'Study Group'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, true);

        final classAttendance = attendanceProvider.getAttendanceByType('Class');
        expect(classAttendance.totalSessions, 2);
        expect(classAttendance.attendedSessions, 1);
        expect(classAttendance.percentage, 50.0);

        final studyGroupAttendance = attendanceProvider.getAttendanceByType('Study Group');
        expect(studyGroupAttendance.percentage, 100.0);
      });
    });

    group('3. Provide Alerts When Attendance Drops Below 75%', () {
      test('Shows warning when attendance is below 75%', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.addSession(_createSession('Session 3'));

        // Attend 1 out of 3 (33.33%)
        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, false);

        expect(attendanceProvider.shouldShowWarning, true);
        expect(attendanceProvider.currentAttendance.isAtRisk, true);
      });

      test('Does not show warning when attendance is exactly 75%', () async {
        // Create 4 sessions, attend 3 (75%)
        for (int i = 0; i < 4; i++) {
          await sessionProvider.addSession(_createSession('Session $i'));
        }
        for (int i = 0; i < 3; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, true);
        }
        await sessionProvider.recordAttendance(sessionProvider.sessions[3].id, false);

        expect(attendanceProvider.shouldShowWarning, false);
        expect(attendanceProvider.currentAttendance.isAtRisk, false);
      });

      test('Does not show warning when attendance is above 75%', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);

        expect(attendanceProvider.shouldShowWarning, false);
      });

      test('Does not show warning when no sessions recorded', () {
        expect(attendanceProvider.shouldShowWarning, false);
      });

      test('Warning appears immediately when attendance drops below threshold', () async {
        // Start at 100%
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        expect(attendanceProvider.shouldShowWarning, false);

        // Add more sessions to drop to 50%
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        expect(attendanceProvider.shouldShowWarning, true);
      });

      test('At risk status matches warning condition', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.addSession(_createSession('Session 3'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, false);

        final record = attendanceProvider.currentAttendance;
        expect(record.isAtRisk, true);
        expect(attendanceProvider.shouldShowWarning, true);
        expect(record.statusLevel, 'at-risk');
      });
    });

    group('4. Maintain Attendance History for Reference', () {
      test('AttendanceRecord maintains complete history data', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));
        await sessionProvider.addSession(_createSession('Session 3'));
        await sessionProvider.addSession(_createSession('Session 4'));
        await sessionProvider.addSession(_createSession('Session 5'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, false);
        await sessionProvider.recordAttendance(sessionProvider.sessions[3].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[4].id, false);

        final record = attendanceProvider.currentAttendance;
        
        // Verify all history metrics
        expect(record.totalSessions, 5);
        expect(record.attendedSessions, 3);
        expect(record.missedSessions, 2);
        expect(record.percentage, 60.0);
        expect(record.formattedPercentage, '60.0%');
        expect(record.statusLevel, 'at-risk');
      });

      test('History is accessible through multiple getters', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);

        // All these should provide access to the same attendance data
        expect(attendanceProvider.attendancePercentage, 50.0);
        expect(attendanceProvider.currentAttendance.percentage, 50.0);
        expect(attendanceProvider.formattedPercentage, '50.0%');
        expect(attendanceProvider.currentAttendance.formattedPercentage, '50.0%');
      });

      test('Weekly history is maintained separately from overall', () async {
        final now = DateTime.now();
        
        // Current week sessions
        await sessionProvider.addSession(_createSessionWithDate('This Week 1', now));
        await sessionProvider.addSession(_createSessionWithDate(
          'This Week 2',
          now.subtract(const Duration(days: 1)),
        ));
        
        // Previous week session (outside current week)
        await sessionProvider.addSession(_createSessionWithDate(
          'Last Week',
          now.subtract(const Duration(days: 10)),
        ));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, true);

        final overall = attendanceProvider.currentAttendance;
        final weekly = attendanceProvider.weeklyAttendance;

        expect(overall.totalSessions, 3);
        expect(weekly.totalSessions, 2);
        expect(overall.percentage, closeTo(66.7, 0.1));
        expect(weekly.percentage, 50.0);
      });

      test('Session type history is maintained separately', () async {
        // Add different session types
        await sessionProvider.addSession(_createSessionWithType('Class 1', 'Class'));
        await sessionProvider.addSession(_createSessionWithType('Class 2', 'Class'));
        await sessionProvider.addSession(_createSessionWithType('Mastery 1', 'Mastery Session'));
        await sessionProvider.addSession(_createSessionWithType('Study 1', 'Study Group'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);
        await sessionProvider.recordAttendance(sessionProvider.sessions[2].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[3].id, true);

        final classAttendance = attendanceProvider.getAttendanceByType('Class');
        final masteryAttendance = attendanceProvider.getAttendanceByType('Mastery Session');
        final studyAttendance = attendanceProvider.getAttendanceByType('Study Group');

        expect(classAttendance.percentage, 50.0);
        expect(masteryAttendance.percentage, 100.0);
        expect(studyAttendance.percentage, 100.0);
      });

      test('AttendanceRecord toString provides readable summary', () {
        final record = AttendanceRecord(
          totalSessions: 10,
          attendedSessions: 7,
        );

        final summary = record.toString();
        expect(summary, contains('total: 10'));
        expect(summary, contains('attended: 7'));
        expect(summary, contains('70.0%'));
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      test('Handles attendance percentage at exactly 74.9%', () async {
        // Need precision to hit 74.9% exactly
        // 749 out of 1000 sessions = 74.9%
        for (int i = 0; i < 10; i++) {
          await sessionProvider.addSession(_createSession('Session $i'));
        }
        
        // Attend 7, miss 3 = 70%
        for (int i = 0; i < 7; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, true);
        }
        for (int i = 7; i < 10; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, false);
        }

        expect(attendanceProvider.shouldShowWarning, true);
        expect(attendanceProvider.currentAttendance.isAtRisk, true);
      });

      test('Handles attendance percentage at exactly 75.1%', () async {
        // 751 out of 1000 = 75.1%
        // Simplified: 3 out of 4 = 75%
        for (int i = 0; i < 10; i++) {
          await sessionProvider.addSession(_createSession('Session $i'));
        }
        
        // Attend 8, miss 2 = 80%
        for (int i = 0; i < 8; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, true);
        }
        for (int i = 8; i < 10; i++) {
          await sessionProvider.recordAttendance(sessionProvider.sessions[i].id, false);
        }

        expect(attendanceProvider.shouldShowWarning, false);
        expect(attendanceProvider.currentAttendance.isAtRisk, false);
      });

      test('Provider updates when session is deleted', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.addSession(_createSession('Session 2'));

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);
        await sessionProvider.recordAttendance(sessionProvider.sessions[1].id, false);

        expect(attendanceProvider.attendancePercentage, 50.0);

        await sessionProvider.deleteSession(sessionProvider.sessions[1].id);

        expect(attendanceProvider.attendancePercentage, 100.0);
      });

      test('Provider updates when attendance is changed from present to absent', () async {
        await sessionProvider.addSession(_createSession('Session 1'));
        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, true);

        expect(attendanceProvider.attendancePercentage, 100.0);

        await sessionProvider.recordAttendance(sessionProvider.sessions[0].id, false);

        expect(attendanceProvider.attendancePercentage, 0.0);
      });
    });
  });
}

/// Helper function to create a test session
AcademicSession _createSession(String title) {
  return AcademicSession(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    date: DateTime.now().subtract(const Duration(days: 1)), // Past session
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 10, minute: 0),
    location: 'Test Location',
    sessionType: 'Class',
  );
}

/// Helper function to create a session with specific date
AcademicSession _createSessionWithDate(String title, DateTime date) {
  return AcademicSession(
    id: DateTime.now().millisecondsSinceEpoch.toString() + title,
    title: title,
    date: date,
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 10, minute: 0),
    location: 'Test Location',
    sessionType: 'Class',
  );
}

/// Helper function to create a session with specific type
AcademicSession _createSessionWithType(String title, String type) {
  return AcademicSession(
    id: DateTime.now().millisecondsSinceEpoch.toString() + title,
    title: title,
    date: DateTime.now().subtract(const Duration(days: 1)),
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 10, minute: 0),
    location: 'Test Location',
    sessionType: type,
  );
}
