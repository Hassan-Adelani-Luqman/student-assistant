import 'package:flutter/material.dart';

/// Model class representing an academic session (class, study group, etc.)
///
/// This class stores information about scheduled academic activities including
/// session type, timing, location, and attendance records.
class AcademicSession {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String sessionType; // Class, Mastery Session, Study Group, PSL Meeting
  bool? attended; // null = not recorded, true = present, false = absent

  AcademicSession({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location = '',
    required this.sessionType,
    this.attended,
  });

  /// Creates an AcademicSession instance from a JSON map
  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: _timeFromString(json['startTime'] as String),
      endTime: _timeFromString(json['endTime'] as String),
      location: json['location'] as String? ?? '',
      sessionType: json['sessionType'] as String,
      attended: json['attended'] as bool?,
    );
  }

  /// Converts the AcademicSession instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': _timeToString(startTime),
      'endTime': _timeToString(endTime),
      'location': location,
      'sessionType': sessionType,
      'attended': attended,
    };
  }

  /// Helper method to convert TimeOfDay to string format (HH:mm)
  static String _timeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Helper method to convert string format (HH:mm) to TimeOfDay
  static TimeOfDay _timeFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Creates a copy of this session with updated fields
  AcademicSession copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? sessionType,
    bool? attended,
  }) {
    return AcademicSession(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      sessionType: sessionType ?? this.sessionType,
      attended: attended ?? this.attended,
    );
  }

  /// Checks if this session is scheduled for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if this session is in the past
  bool get isPast {
    return date.isBefore(DateTime.now());
  }

  /// Returns formatted time range string (e.g., "09:00 - 10:30")
  String get timeRange {
    return '${_timeToString(startTime)} - ${_timeToString(endTime)}';
  }
}
