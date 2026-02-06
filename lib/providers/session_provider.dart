import 'package:flutter/foundation.dart';
import '../models/academic_session.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

/// Provider class for managing academic sessions state
///
/// Enhanced with robust error handling, loading states, and retry mechanisms
/// for reliable data persistence
class SessionProvider with ChangeNotifier {
  List<AcademicSession> _sessions = [];
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  String? _lastError;
  bool _hasPendingSave = false;
  void Function(String)? _onError;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  List<AcademicSession> get sessions => [..._sessions];
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get hasPendingSave => _hasPendingSave;
  int get retryCount => _retryCount;

  /// Set error callback for UI notifications
  void setErrorCallback(void Function(String) callback) {
    _onError = callback;
  }

  /// Returns sessions scheduled for today
  List<AcademicSession> get todaysSessions {
    return _sessions.where((s) => s.isToday).toList()..sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  /// Returns sessions for a specific date
  List<AcademicSession> getSessionsForDate(DateTime date) {
    return _sessions.where((s) {
      return s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day;
    }).toList()..sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  /// Returns sessions for the current week
  List<AcademicSession> get weeklySessions {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return _sessions.where((s) {
      return s.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          s.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns sessions filtered by type
  List<AcademicSession> getSessionsByType(String type) {
    return _sessions.where((s) => s.sessionType == type).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns dates that have at least one session
  Set<DateTime> get datesWithSessions {
    return _sessions.map((s) {
      return DateTime(s.date.year, s.date.month, s.date.day);
    }).toSet();
  }

  /// Loads sessions from persistent storage with error handling
  Future<bool> loadSessions() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _sessions = await _storageService.loadSessions();
      _sessions.sort((a, b) => a.date.compareTo(b.date));
      _retryCount = 0;
      debugPrint('Loaded ${_sessions.length} sessions successfully');
      return true;
    } catch (e, stackTrace) {
      _lastError = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logError(
        'SessionProvider.loadSessions',
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

  /// Adds a new session
  Future<void> addSession(AcademicSession session) async {
    _sessions.add(session);
    _sessions.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
    await _saveSessions();
  }

  /// Updates an existing session
  Future<void> updateSession(String id, AcademicSession updatedSession) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index] = updatedSession;
      _sessions.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
      await _saveSessions();
    }
  }

  /// Records attendance for a session
  Future<void> recordAttendance(String id, bool attended) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(attended: attended);
      notifyListeners();
      await _saveSessions();
    }
  }

  /// Deletes a session
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
    await _saveSessions();
  }

  /// Saves sessions to persistent storage with retry logic
  Future<bool> _saveSessions() async {
    _hasPendingSave = true;
    _lastError = null;
    notifyListeners();

    final success = await ErrorHandler.withRetry(
      operation: () async {
        final result = await _storageService.saveSessions(_sessions);
        if (!result) {
          throw StorageException('Failed to save sessions');
        }
        return result;
      },
      context: 'SessionProvider._saveSessions',
      maxRetries: _maxRetries,
      onError: (errorMessage) {
        _lastError = errorMessage;
        _onError?.call(errorMessage);
      },
    );

    if (success == true) {
      _retryCount = 0;
      debugPrint('Saved ${_sessions.length} sessions successfully');
      _hasPendingSave = false;
      notifyListeners();
      return true;
    } else {
      _retryCount++;
      ErrorHandler.logError(
        'SessionProvider._saveSessions',
        'Failed after $retryCount retries',
      );
      notifyListeners();
      return false;
    }
  }

  /// Retries pending save operation
  Future<bool> retrySave() async {
    if (_hasPendingSave) {
      return await _saveSessions();
    }
    return true;
  }

  /// Clears the last error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Returns count of sessions with recorded attendance
  int get recordedSessionsCount {
    return _sessions.where((s) => s.attended != null).length;
  }

  /// Returns count of attended sessions
  int get attendedSessionsCount {
    return _sessions.where((s) => s.attended == true).length;
  }
}
