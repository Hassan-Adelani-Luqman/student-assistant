/// Constants used throughout the Student Assistant application
///
/// This file centralizes all constant values to ensure consistency
/// and make it easier to update values across the application.
library;

/// Course-related constants
class CourseConstants {
  // Private constructor to prevent instantiation
  CourseConstants._();

  /// Default list of available courses
  static const List<String> availableCourses = [
    'All Selected Courses',
    'Introduction to Linux',
    'Front End Web Development',
    'Python Programming',
  ];

  /// Default selected course
  static const String defaultCourse = 'All Selected Courses';
}

/// Attendance-related constants
class AttendanceConstants {
  // Private constructor to prevent instantiation
  AttendanceConstants._();

  /// Minimum acceptable attendance percentage (75%)
  static const double minimumAttendancePercentage = 75.0;

  /// Attendance percentage threshold for warnings
  static const double warningThreshold = 75.0;

  /// Attendance percentage for good standing (>= 80%)
  static const double goodAttendanceThreshold = 80.0;

  /// Attendance percentage for critical status (< 70%)
  static const double criticalAttendanceThreshold = 70.0;
}

/// Storage-related constants
class StorageConstants {
  // Private constructor to prevent instantiation
  StorageConstants._();

  /// Maximum storage size for assignments (5MB)
  static const int maxAssignmentStorageSize = 5 * 1024 * 1024;

  /// Maximum storage size for sessions (5MB)
  static const int maxSessionStorageSize = 5 * 1024 * 1024;

  /// Maximum number of retry attempts for storage operations
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts (milliseconds)
  static const int retryDelayMs = 1000;

  /// Storage keys
  static const String assignmentsKey = 'assignments';
  static const String sessionsKey = 'sessions';
  static const String assignmentsBackupKey = 'assignments_backup';
  static const String sessionsBackupKey = 'sessions_backup';
}

/// Date and time related constants
class DateTimeConstants {
  // Private constructor to prevent instantiation
  DateTimeConstants._();

  /// Number of days to look ahead for upcoming assignments
  static const int upcomingDaysWindow = 7;

  /// Number of days to consider an assignment as "due soon"
  static const int dueSoonDaysThreshold = 3;

  /// Number of days to consider an assignment as "due very soon"
  static const int dueVerySoonDaysThreshold = 1;
}

/// UI-related constants
class UIConstants {
  // Private constructor to prevent instantiation
  UIConstants._();

  /// Default border radius for cards and containers
  static const double defaultBorderRadius = 12.0;

  /// Default padding for screen content
  static const double defaultScreenPadding = 16.0;

  /// Default spacing between elements
  static const double defaultSpacing = 16.0;

  /// Small spacing between elements
  static const double smallSpacing = 8.0;

  /// Large spacing between sections
  static const double largeSpacing = 24.0;

  /// Default animation duration (milliseconds)
  static const int defaultAnimationDurationMs = 300;

  /// Page transition duration (milliseconds)
  static const int pageTransitionDurationMs = 300;

  /// Snackbar duration (milliseconds)
  static const int snackbarDurationMs = 4000;

  /// Error snackbar duration (milliseconds)
  static const int errorSnackbarDurationMs = 4000;
}

/// Session type constants
class SessionTypeConstants {
  // Private constructor to prevent instantiation
  SessionTypeConstants._();

  /// Available session types
  static const List<String> sessionTypes = [
    'All',
    'Class',
    'Mastery Session',
    'Study Group',
    'PSL Meeting',
  ];

  /// Default session type
  static const String defaultSessionType = 'All';
}

/// Assignment priority constants
class AssignmentPriorityConstants {
  // Private constructor to prevent instantiation
  AssignmentPriorityConstants._();

  /// Priority levels
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';

  /// Default priority
  static const String defaultPriority = medium;

  /// Available priorities
  static const List<String> priorities = [high, medium, low];
}

/// Validation constants
class ValidationConstants {
  // Private constructor to prevent instantiation
  ValidationConstants._();

  /// Minimum title length
  static const int minTitleLength = 1;

  /// Maximum title length
  static const int maxTitleLength = 100;

  /// Minimum description length
  static const int minDescriptionLength = 0;

  /// Maximum description length
  static const int maxDescriptionLength = 500;

  /// Minimum course name length
  static const int minCourseNameLength = 1;

  /// Maximum course name length
  static const int maxCourseNameLength = 100;

  /// Error messages
  static const String emptyTitleError = 'Title is required';
  static const String emptyCourseNameError = 'Course name is required';
  static const String titleTooLongError =
      'Title is too long (max 100 characters)';
  static const String descriptionTooLongError =
      'Description is too long (max 500 characters)';
}
