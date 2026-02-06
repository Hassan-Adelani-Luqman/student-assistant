import 'package:flutter/foundation.dart';
import '../models/assignment.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

/// Provider class for managing assignments state
///
/// Enhanced with robust error handling, loading states, and retry mechanisms
/// for reliable data persistence
class AssignmentProvider with ChangeNotifier {
  List<Assignment> _assignments = [];
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  String? _lastError;
  bool _hasPendingSave = false;
  void Function(String)? _onError;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  List<Assignment> get assignments => [..._assignments];
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get hasPendingSave => _hasPendingSave;
  int get retryCount => _retryCount;

  /// Set error callback for UI notifications
  void setErrorCallback(void Function(String) callback) {
    _onError = callback;
  }

  /// Returns all incomplete assignments
  List<Assignment> get incompleteAssignments {
    return _assignments.where((a) => !a.isCompleted).toList();
  }

  /// Returns all completed assignments
  List<Assignment> get completedAssignments {
    return _assignments.where((a) => a.isCompleted).toList();
  }

  /// Returns count of completed assignments
  int get completedCount {
    return _assignments.where((a) => a.isCompleted).length;
  }

  /// Returns count of pending (incomplete) assignments
  int get pendingCount {
    return _assignments.where((a) => !a.isCompleted).length;
  }

  /// Returns assignments due within the next 7 days
  List<Assignment> getUpcomingAssignments({int days = 7}) {
    return _assignments
        .where((a) => !a.isCompleted && a.isDueWithinDays(days))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Returns overdue assignments that are not completed
  List<Assignment> get overdueAssignments {
    return _assignments.where((a) => a.isOverdue).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Loads assignments from persistent storage with error handling
  Future<bool> loadAssignments() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _assignments = await _storageService.loadAssignments();
      _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      _retryCount = 0;
      debugPrint('Loaded ${_assignments.length} assignments successfully');
      return true;
    } catch (e, stackTrace) {
      _lastError = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logError(
        'AssignmentProvider.loadAssignments',
        e,
        stackTrace: stackTrace,
      );
      _onError?.call(_lastError!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new assignment
  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
    await _saveAssignments();
  }

  /// Updates an existing assignment
  Future<void> updateAssignment(String id, Assignment updatedAssignment) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _assignments[index] = updatedAssignment;
      _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
      await _saveAssignments();
    }
  }

  /// Toggles the completion status of an assignment
  Future<void> toggleComplete(String id) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _assignments[index].isCompleted = !_assignments[index].isCompleted;
      notifyListeners();
      await _saveAssignments();
    }
  }

  /// Deletes an assignment
  Future<void> deleteAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
    await _saveAssignments();
  }

  /// Saves assignments to persistent storage with retry logic
  Future<bool> _saveAssignments() async {
    _hasPendingSave = true;
    _lastError = null;
    notifyListeners();

    final success = await ErrorHandler.withRetry(
      operation: () async {
        final result = await _storageService.saveAssignments(_assignments);
        if (!result) {
          throw StorageException('Failed to save assignments');
        }
        return result;
      },
      context: 'AssignmentProvider._saveAssignments',
      maxRetries: _maxRetries,
      onError: (errorMessage) {
        _lastError = errorMessage;
        _onError?.call(errorMessage);
      },
    );

    if (success == true) {
      _retryCount = 0;
      debugPrint('Saved ${_assignments.length} assignments successfully');
      _hasPendingSave = false;
      notifyListeners();
      return true;
    } else {
      _retryCount++;
      ErrorHandler.logError(
        'AssignmentProvider._saveAssignments',
        'Failed after $retryCount retries',
      );
      notifyListeners();
      return false;
    }
  }

  /// Retries pending save operation
  Future<bool> retrySave() async {
    if (_hasPendingSave) {
      return await _saveAssignments();
    }
    return true;
  }

  /// Clears the last error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
