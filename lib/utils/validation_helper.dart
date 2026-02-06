import 'package:flutter/material.dart';

/// Input validation utilities for forms
class ValidationHelper {
  /// Validates required text field
  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates text field with minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates text field with maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'This field',
  }) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates text field with length range
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength, {
    String fieldName = 'This field',
  }) {
    final requiredError = validateRequired(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    final length = value!.trim().length;
    if (length < minLength || length > maxLength) {
      return '$fieldName must be between $minLength and $maxLength characters';
    }
    return null;
  }

  /// Validates that date is in the future
  static String? validateFutureDate(
    DateTime? date, {
    String fieldName = 'Date',
  }) {
    if (date == null) {
      return '$fieldName is required';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay.isBefore(today)) {
      return '$fieldName must be today or in the future';
    }
    return null;
  }

  /// Validates that date is not too far in the future
  static String? validateDateRange(
    DateTime? date,
    int maxDaysAhead, {
    String fieldName = 'Date',
  }) {
    if (date == null) {
      return '$fieldName is required';
    }
    final now = DateTime.now();
    final maxDate = now.add(Duration(days: maxDaysAhead));

    if (date.isAfter(maxDate)) {
      return '$fieldName cannot be more than $maxDaysAhead days in the future';
    }
    return null;
  }

  /// Validates that end time is after start time
  static String? validateTimeRange(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) {
      return null; // Individual time validation should handle null
    }

    final start = startTime.hour * 60 + startTime.minute;
    final end = endTime.hour * 60 + endTime.minute;

    if (end <= start) {
      return 'End time must be after start time';
    }

    return null;
  }

  /// Validates minimum duration between times (in minutes)
  static String? validateMinDuration(
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int minMinutes,
  ) {
    final timeRangeError = validateTimeRange(startTime, endTime);
    if (timeRangeError != null) return timeRangeError;

    final start = startTime!.hour * 60 + startTime.minute;
    final end = endTime!.hour * 60 + endTime.minute;
    final duration = end - start;

    if (duration < minMinutes) {
      return 'Duration must be at least $minMinutes minutes';
    }

    return null;
  }

  /// Validates maximum duration between times (in minutes)
  static String? validateMaxDuration(
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int maxMinutes,
  ) {
    final timeRangeError = validateTimeRange(startTime, endTime);
    if (timeRangeError != null) return timeRangeError;

    final start = startTime!.hour * 60 + startTime.minute;
    final end = endTime!.hour * 60 + endTime.minute;
    final duration = end - start;

    if (duration > maxMinutes) {
      return 'Duration cannot exceed $maxMinutes minutes';
    }

    return null;
  }

  /// Validates that a field contains only letters and spaces
  static String? validateAlphabetic(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final alphaRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!alphaRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }

  /// Validates alphanumeric with common punctuation
  static String? validateAlphanumeric(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9\s\-\.\,\:\(\)]+$');
    if (!alphanumericRegex.hasMatch(value.trim())) {
      return '$fieldName contains invalid characters';
    }
    return null;
  }

  /// Validates that start date is before or equal to end date
  static String? validateDateOrder(
    DateTime? startDate,
    DateTime? endDate, {
    String startLabel = 'Start date',
    String endLabel = 'End date',
  }) {
    if (startDate == null || endDate == null) {
      return null;
    }

    if (startDate.isAfter(endDate)) {
      return '$endLabel must be after $startLabel';
    }

    return null;
  }

  /// Combines multiple validators
  static String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Validates course name format (letters, numbers, spaces, hyphens)
  static String? validateCourseName(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Course name');
    if (requiredError != null) return requiredError;

    final lengthError = validateLength(value, 2, 50, fieldName: 'Course name');
    if (lengthError != null) return lengthError;

    final formatRegex = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    if (!formatRegex.hasMatch(value!.trim())) {
      return 'Course name can only contain letters, numbers, spaces, and hyphens';
    }

    return null;
  }

  /// Validates assignment title
  static String? validateAssignmentTitle(String? value) {
    final requiredError = validateRequired(
      value,
      fieldName: 'Assignment title',
    );
    if (requiredError != null) return requiredError;

    final lengthError = validateLength(
      value,
      3,
      100,
      fieldName: 'Assignment title',
    );
    if (lengthError != null) return lengthError;

    return null;
  }

  /// Validates session title
  static String? validateSessionTitle(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Session title');
    if (requiredError != null) return requiredError;

    final lengthError = validateLength(
      value,
      3,
      100,
      fieldName: 'Session title',
    );
    if (lengthError != null) return lengthError;

    return null;
  }

  /// Validates location (optional but with max length)
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Location is optional
    }

    final lengthError = validateMaxLength(value, 100, fieldName: 'Location');
    if (lengthError != null) return lengthError;

    return null;
  }

  /// Validates assignment due date
  static String? validateAssignmentDueDate(DateTime? date) {
    final futureError = validateFutureDate(date, fieldName: 'Due date');
    if (futureError != null) return futureError;

    final rangeError = validateDateRange(date, 365, fieldName: 'Due date');
    if (rangeError != null) return rangeError;

    return null;
  }
}
