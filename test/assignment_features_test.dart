import 'package:flutter_test/flutter_test.dart';
import 'package:student_assistant/models/assignment.dart';
import 'package:student_assistant/providers/assignment_provider.dart';

/// Comprehensive test suite for Assignment Management System
/// 
/// Tests all required features:
/// 1. Create assignments with title, due date, course, priority, and type
/// 2. View all assignments sorted by due date
/// 3. Mark assignments as completed
/// 4. Remove assignments
/// 5. Edit assignment details
void main() {
  group('Assignment Management System - Feature Tests', () {
    late AssignmentProvider provider;

    setUp(() {
      provider = AssignmentProvider();
    });

    group('1. Create New Assignments', () {
      test('Create assignment with all required fields', () async {
        // Arrange
        final assignment = Assignment(
          id: '1',
          title: 'Complete Flutter Project',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          courseName: 'Mobile Development',
          priority: 'High',
          assignmentType: 'Summative',
        );

        // Act
        await provider.addAssignment(assignment);

        // Assert
        expect(provider.assignments.length, 1);
        expect(provider.assignments.first.title, 'Complete Flutter Project');
        expect(provider.assignments.first.courseName, 'Mobile Development');
        expect(provider.assignments.first.priority, 'High');
        expect(provider.assignments.first.assignmentType, 'Summative');
      });

      test('Create assignment with required title', () async {
        // Arrange
        final assignment = Assignment(
          id: '2',
          title: 'Math Homework',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          courseName: 'Mathematics',
        );

        // Act
        await provider.addAssignment(assignment);

        // Assert
        expect(provider.assignments.any((a) => a.title == 'Math Homework'), true);
        expect(provider.assignments.last.title.isNotEmpty, true);
      });

      test('Create assignment with due date (date picker)', () async {
        // Arrange
        final dueDate = DateTime(2026, 2, 10);
        final assignment = Assignment(
          id: '3',
          title: 'Essay Submission',
          dueDate: dueDate,
          courseName: 'English',
        );

        // Act
        await provider.addAssignment(assignment);

        // Assert
        expect(provider.assignments.last.dueDate, dueDate);
      });

      test('Create assignment with course name', () async {
        // Arrange
        final assignment = Assignment(
          id: '4',
          title: 'Lab Report',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Physics',
        );

        // Act
        await provider.addAssignment(assignment);

        // Assert
        expect(provider.assignments.last.courseName, 'Physics');
      });

      test('Create assignment with priority levels (High/Medium/Low)', () async {
        // Arrange & Act
        await provider.addAssignment(Assignment(
          id: '5',
          title: 'High Priority Task',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          courseName: 'Course A',
          priority: 'High',
        ));

        await provider.addAssignment(Assignment(
          id: '6',
          title: 'Medium Priority Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course B',
          priority: 'Medium',
        ));

        await provider.addAssignment(Assignment(
          id: '7',
          title: 'Low Priority Task',
          dueDate: DateTime.now().add(const Duration(days: 10)),
          courseName: 'Course C',
          priority: 'Low',
        ));

        // Assert
        expect(provider.assignments.any((a) => a.priority == 'High'), true);
        expect(provider.assignments.any((a) => a.priority == 'Medium'), true);
        expect(provider.assignments.any((a) => a.priority == 'Low'), true);
      });

      test('Create assignment with default priority (Medium)', () async {
        // Arrange
        final assignment = Assignment(
          id: '8',
          title: 'Task with default priority',
          dueDate: DateTime.now().add(const Duration(days: 4)),
          courseName: 'Course D',
        );

        // Act
        await provider.addAssignment(assignment);

        // Assert
        expect(provider.assignments.last.priority, 'Medium');
      });

      test('Create assignment with assignment type (Formative/Summative)', () async {
        // Arrange & Act
        await provider.addAssignment(Assignment(
          id: '9',
          title: 'Formative Quiz',
          dueDate: DateTime.now().add(const Duration(days: 2)),
          courseName: 'Course E',
          assignmentType: 'Formative',
        ));

        await provider.addAssignment(Assignment(
          id: '10',
          title: 'Final Exam',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          courseName: 'Course F',
          assignmentType: 'Summative',
        ));

        // Assert
        expect(provider.assignments.any((a) => a.assignmentType == 'Formative'), true);
        expect(provider.assignments.any((a) => a.assignmentType == 'Summative'), true);
      });
    });

    group('2. View All Assignments Sorted by Due Date', () {
      test('Assignments are sorted by due date (ascending)', () async {
        // Arrange
        final today = DateTime.now();
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Due in 10 days',
          dueDate: today.add(const Duration(days: 10)),
          courseName: 'Course',
        ));
        await provider.addAssignment(Assignment(
          id: '2',
          title: 'Due in 2 days',
          dueDate: today.add(const Duration(days: 2)),
          courseName: 'Course',
        ));
        await provider.addAssignment(Assignment(
          id: '3',
          title: 'Due in 5 days',
          dueDate: today.add(const Duration(days: 5)),
          courseName: 'Course',
        ));

        // Act
        await provider.loadAssignments();

        // Assert
        final assignments = provider.assignments;
        expect(assignments.length, 3);
        expect(assignments[0].title, 'Due in 2 days');
        expect(assignments[1].title, 'Due in 5 days');
        expect(assignments[2].title, 'Due in 10 days');
        
        // Verify sorting
        for (int i = 0; i < assignments.length - 1; i++) {
          expect(
            assignments[i].dueDate.isBefore(assignments[i + 1].dueDate) ||
            assignments[i].dueDate.isAtSameMomentAs(assignments[i + 1].dueDate),
            true,
          );
        }
      });

      test('View all assignments returns complete list', () async {
        // Arrange
        for (int i = 0; i < 5; i++) {
          await provider.addAssignment(Assignment(
            id: '$i',
            title: 'Assignment $i',
            dueDate: DateTime.now().add(Duration(days: i)),
            courseName: 'Course $i',
          ));
        }

        // Act
        final allAssignments = provider.assignments;

        // Assert
        expect(allAssignments.length, 5);
      });

      test('Upcoming assignments (within 7 days) are correctly filtered and sorted', () async {
        // Arrange
        final today = DateTime.now();
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Due in 3 days',
          dueDate: today.add(const Duration(days: 3)),
          courseName: 'Course',
        ));
        await provider.addAssignment(Assignment(
          id: '2',
          title: 'Due in 15 days',
          dueDate: today.add(const Duration(days: 15)),
          courseName: 'Course',
        ));
        await provider.addAssignment(Assignment(
          id: '3',
          title: 'Due in 1 day',
          dueDate: today.add(const Duration(days: 1)),
          courseName: 'Course',
        ));

        // Act
        final upcoming = provider.getUpcomingAssignments(days: 7);

        // Assert
        expect(upcoming.length, 2);
        expect(upcoming[0].title, 'Due in 1 day');
        expect(upcoming[1].title, 'Due in 3 days');
      });
    });

    group('3. Mark Assignments as Completed', () {
      test('Toggle assignment completion status', () async {
        // Arrange
        final assignment = Assignment(
          id: '1',
          title: 'Complete Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          isCompleted: false,
        );
        await provider.addAssignment(assignment);

        // Act
        provider.toggleComplete('1');

        // Assert
        expect(provider.assignments.first.isCompleted, true);
      });

      test('Mark completed assignment as incomplete (toggle back)', () async {
        // Arrange
        final assignment = Assignment(
          id: '1',
          title: 'Completed Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          isCompleted: true,
        );
        await provider.addAssignment(assignment);

        // Act
        provider.toggleComplete('1');

        // Assert
        expect(provider.assignments.first.isCompleted, false);
      });

      test('Completed assignments count is accurate', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task 1',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          isCompleted: true,
        ));
        await provider.addAssignment(Assignment(
          id: '2',
          title: 'Task 2',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          isCompleted: false,
        ));
        await provider.addAssignment(Assignment(
          id: '3',
          title: 'Task 3',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          isCompleted: true,
        ));

        // Act
        final completedCount = provider.completedCount;
        final pendingCount = provider.pendingCount;

        // Assert
        expect(completedCount, 2);
        expect(pendingCount, 1);
      });

      test('Incomplete assignments list excludes completed ones', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Incomplete Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          isCompleted: false,
        ));
        await provider.addAssignment(Assignment(
          id: '2',
          title: 'Completed Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          isCompleted: true,
        ));

        // Act
        final incomplete = provider.incompleteAssignments;

        // Assert
        expect(incomplete.length, 1);
        expect(incomplete.first.title, 'Incomplete Task');
      });
    });

    group('4. Remove Assignments from List', () {
      test('Delete assignment by ID', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task to Delete',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
        ));
        expect(provider.assignments.length, 1);

        // Act
        await provider.deleteAssignment('1');

        // Assert
        expect(provider.assignments.length, 0);
      });

      test('Delete specific assignment from multiple assignments', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task 1',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
        ));
        await provider.addAssignment(Assignment(
          id: '2',
          title: 'Task 2',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
        ));
        await provider.addAssignment(Assignment(
          id: '3',
          title: 'Task 3',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
        ));

        // Act
        await provider.deleteAssignment('2');

        // Assert
        expect(provider.assignments.length, 2);
        expect(provider.assignments.any((a) => a.id == '2'), false);
        expect(provider.assignments.any((a) => a.id == '1'), true);
        expect(provider.assignments.any((a) => a.id == '3'), true);
      });

      test('Deleting non-existent assignment does not cause error', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task 1',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
        ));

        // Act & Assert - should not throw
        expect(() async => await provider.deleteAssignment('999'), returnsNormally);
      });
    });

    group('5. Edit Assignment Details', () {
      test('Update assignment title', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Original Title',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
        ));

        // Act
        final updated = provider.assignments.first.copyWith(
          title: 'Updated Title',
        );
        await provider.updateAssignment('1', updated);

        // Assert
        expect(provider.assignments.first.title, 'Updated Title');
      });

      test('Update assignment due date', () async {
        // Arrange
        final originalDate = DateTime(2026, 2, 10);
        final newDate = DateTime(2026, 2, 15);
        
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task',
          dueDate: originalDate,
          courseName: 'Course',
        ));

        // Act
        final updated = provider.assignments.first.copyWith(
          dueDate: newDate,
        );
        await provider.updateAssignment('1', updated);

        // Assert
        expect(provider.assignments.first.dueDate, newDate);
      });

      test('Update assignment course name', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Old Course',
        ));

        // Act
        final updated = provider.assignments.first.copyWith(
          courseName: 'New Course',
        );
        await provider.updateAssignment('1', updated);

        // Assert
        expect(provider.assignments.first.courseName, 'New Course');
      });

      test('Update assignment priority', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          priority: 'Low',
        ));

        // Act
        final updated = provider.assignments.first.copyWith(
          priority: 'High',
        );
        await provider.updateAssignment('1', updated);

        // Assert
        expect(provider.assignments.first.priority, 'High');
      });

      test('Update assignment type', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Task',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Course',
          assignmentType: 'Formative',
        ));

        // Act
        final updated = provider.assignments.first.copyWith(
          assignmentType: 'Summative',
        );
        await provider.updateAssignment('1', updated);

        // Assert
        expect(provider.assignments.first.assignmentType, 'Summative');
      });

      test('Update multiple fields simultaneously', () async {
        // Arrange
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Old Task',
          dueDate: DateTime(2026, 2, 10),
          courseName: 'Old Course',
          priority: 'Low',
          assignmentType: 'Formative',
        ));

        // Act
        final updated = provider.assignments.first.copyWith(
          title: 'New Task',
          dueDate: DateTime(2026, 2, 20),
          courseName: 'New Course',
          priority: 'High',
          assignmentType: 'Summative',
        );
        await provider.updateAssignment('1', updated);

        // Assert
        final result = provider.assignments.first;
        expect(result.title, 'New Task');
        expect(result.dueDate, DateTime(2026, 2, 20));
        expect(result.courseName, 'New Course');
        expect(result.priority, 'High');
        expect(result.assignmentType, 'Summative');
      });
    });

    group('Additional Feature Tests', () {
      test('Overdue assignments are correctly identified', () async {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Overdue Task',
          dueDate: yesterday,
          courseName: 'Course',
          isCompleted: false,
        ));

        // Act
        final overdue = provider.overdueAssignments;

        // Assert
        expect(overdue.length, 1);
        expect(overdue.first.title, 'Overdue Task');
      });

      test('Completed assignments are not shown as overdue', () async {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        await provider.addAssignment(Assignment(
          id: '1',
          title: 'Completed Overdue Task',
          dueDate: yesterday,
          courseName: 'Course',
          isCompleted: true,
        ));

        // Act
        final overdue = provider.overdueAssignments;

        // Assert
        expect(overdue.length, 0);
      });

      test('Assignment due within days is correctly calculated', () async {
        // Arrange
        final assignment = Assignment(
          id: '1',
          title: 'Due in 3 days',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          courseName: 'Course',
        );

        // Act & Assert
        expect(assignment.isDueWithinDays(5), true);
        expect(assignment.isDueWithinDays(2), false);
      });
    });
  });
}
