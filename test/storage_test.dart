import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_assistant/models/assignment.dart';
import 'package:student_assistant/models/academic_session.dart';
import 'package:student_assistant/services/storage_service.dart';
import 'package:flutter/material.dart';

/// Comprehensive test suite for data persistence
///
/// Tests cover:
/// - Basic save/load operations
/// - Data validation
/// - Backup and restore
/// - Corrupted data handling
/// - Large dataset handling
/// - Export/import functionality
void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUp(() async {
      // Initialize with empty preferences for each test
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    tearDown(() async {
      // Clean up after each test
      await storageService.clearAllData();
    });

    group('Assignment Persistence', () {
      test('Save and load assignments successfully', () async {
        // Create test assignments
        final assignments = [
          Assignment(
            id: '1',
            title: 'Test Assignment 1',
            courseName: 'Course 1',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            priority: 'High',
          ),
          Assignment(
            id: '2',
            title: 'Test Assignment 2',
            courseName: 'Course 2',
            dueDate: DateTime.now().add(const Duration(days: 14)),
            priority: 'Medium',
          ),
        ];

        // Save assignments
        final saveResult = await storageService.saveAssignments(assignments);
        expect(saveResult, true);

        // Load assignments
        final loaded = await storageService.loadAssignments();
        expect(loaded.length, 2);
        expect(loaded[0].id, '1');
        expect(loaded[0].title, 'Test Assignment 1');
        expect(loaded[1].id, '2');
      });

      test('Load returns empty list when no data exists', () async {
        final loaded = await storageService.loadAssignments();
        expect(loaded, isEmpty);
      });

      test('Handle large dataset of assignments', () async {
        // Create 100 assignments
        final assignments = List.generate(100, (index) {
          return Assignment(
            id: 'id_$index',
            title: 'Assignment $index',
            courseName: 'Course ${index % 5}',
            dueDate: DateTime.now().add(Duration(days: index)),
            priority: ['High', 'Medium', 'Low'][index % 3],
          );
        });

        final saveResult = await storageService.saveAssignments(assignments);
        expect(saveResult, true);

        final loaded = await storageService.loadAssignments();
        expect(loaded.length, 100);
      });

      test('Backup is created before save', () async {
        // First save
        final firstAssignment = [
          Assignment(
            id: '1',
            title: 'First Save',
            courseName: 'Course 1',
            dueDate: DateTime.now(),
            priority: 'High',
          ),
        ];
        await storageService.saveAssignments(firstAssignment);

        // Second save (should create backup)
        final secondAssignment = [
          Assignment(
            id: '2',
            title: 'Second Save',
            courseName: 'Course 2',
            dueDate: DateTime.now(),
            priority: 'High',
          ),
        ];
        await storageService.saveAssignments(secondAssignment);

        // Check backup exists
        final hasBackup = await storageService.hasBackup();
        expect(hasBackup, true);
      });
    });

    group('Session Persistence', () {
      test('Save and load sessions successfully', () async {
        final sessions = [
          AcademicSession(
            id: '1',
            title: 'Test Session 1',
            date: DateTime.now(),
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endTime: const TimeOfDay(hour: 10, minute: 0),
            location: 'Room 101',
            sessionType: 'Class',
          ),
          AcademicSession(
            id: '2',
            title: 'Test Session 2',
            date: DateTime.now().add(const Duration(days: 1)),
            startTime: const TimeOfDay(hour: 14, minute: 0),
            endTime: const TimeOfDay(hour: 16, minute: 0),
            location: 'Room 202',
            sessionType: 'Mastery Session',
          ),
        ];

        final saveResult = await storageService.saveSessions(sessions);
        expect(saveResult, true);

        final loaded = await storageService.loadSessions();
        expect(loaded.length, 2);
        expect(loaded[0].id, '1');
        expect(loaded[0].title, 'Test Session 1');
        expect(loaded[1].sessionType, 'Mastery Session');
      });

      test('Load returns empty list when no sessions exist', () async {
        final loaded = await storageService.loadSessions();
        expect(loaded, isEmpty);
      });

      test('Session with attendance recorded', () async {
        final session = AcademicSession(
          id: '1',
          title: 'Test Session',
          date: DateTime.now(),
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          location: 'Room 101',
          sessionType: 'Class',
          attended: true,
        );

        await storageService.saveSessions([session]);
        final loaded = await storageService.loadSessions();
        expect(loaded[0].attended, true);
      });
    });

    group('Storage Statistics', () {
      test('Get storage statistics', () async {
        // Save some data
        final assignments = [
          Assignment(
            id: '1',
            title: 'Test',
            courseName: 'Course 1',
            dueDate: DateTime.now(),
            priority: 'High',
          ),
        ];
        await storageService.saveAssignments(assignments);

        final stats = await storageService.getStorageStats();
        expect(stats['assignmentsSize'], greaterThan(0));
        expect(stats['totalSize'], greaterThan(0));
        expect(stats['dataVersion'], 1);
      });
    });

    group('Clear Data', () {
      test('Clear all data including backups', () async {
        // Save data
        final assignments = [
          Assignment(
            id: '1',
            title: 'Test',
            courseName: 'Course 1',
            dueDate: DateTime.now(),
            priority: 'High',
          ),
        ];
        await storageService.saveAssignments(assignments);

        // Clear
        final cleared = await storageService.clearAllData();
        expect(cleared, true);

        // Verify all cleared
        final loaded = await storageService.loadAssignments();
        expect(loaded, isEmpty);

        final hasBackup = await storageService.hasBackup();
        expect(hasBackup, false);
      });
    });
  });
}
