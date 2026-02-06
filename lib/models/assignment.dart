/// Model class representing a student assignment
///
/// This class encapsulates all the information about an assignment including
/// its title, due date, course, priority level, and completion status.
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final String priority; // High, Medium, Low
  final String assignmentType; // Formative or Summative
  final String collaborationType; // Group or Individual
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority = 'Medium',
    this.assignmentType = 'Formative',
    this.collaborationType = 'Individual',
    this.isCompleted = false,
  });

  /// Creates an Assignment instance from a JSON map
  /// Used for loading data from persistent storage
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      courseName: json['courseName'] as String,
      priority: json['priority'] as String? ?? 'Medium',
      assignmentType: json['assignmentType'] as String? ?? 'Formative',
      collaborationType: json['collaborationType'] as String? ?? 'Individual',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Converts the Assignment instance to a JSON map
  /// Used for saving data to persistent storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority,
      'assignmentType': assignmentType,
      'collaborationType': collaborationType,
      'isCompleted': isCompleted,
    };
  }

  /// Creates a copy of this assignment with updated fields
  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? courseName,
    String? priority,
    String? assignmentType,
    String? collaborationType,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      assignmentType: assignmentType ?? this.assignmentType,
      collaborationType: collaborationType ?? this.collaborationType,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Checks if the assignment is due within the specified number of days
  bool isDueWithinDays(int days) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= days;
  }

  /// Checks if the assignment is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && !isCompleted;
  }
}
