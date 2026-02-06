import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/academic_session.dart';
import '../utils/error_handler.dart';

/// Service class for handling data persistence using SharedPreferences
///
/// Enhanced with robust error handling, data validation, backup mechanism,
/// and data integrity checks to ensure reliable data persistence across app restarts
class StorageService {
  // Keys for storing data in SharedPreferences
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';
  static const String _assignmentsBackupKey = 'assignments_backup';
  static const String _sessionsBackupKey = 'sessions_backup';
  static const String _dataVersionKey = 'data_version';

  // Current data version for migration support
  static const int _currentDataVersion = 1;

  // Maximum allowed JSON string size (5MB)
  static const int _maxJsonSize = 5 * 1024 * 1024;

  /// Saves a list of assignments to local storage with backup
  ///
  /// Creates a backup before saving to prevent data loss on corruption
  /// Validates data before and after save operation
  Future<bool> saveAssignments(List<Assignment> assignments) async {
    return await ErrorHandler.execute(
          operation: () async {
            final prefs = await SharedPreferences.getInstance();

            // Validate input data
            if (!_validateAssignments(assignments)) {
              ErrorHandler.logError(
                'saveAssignments',
                'Invalid assignments data detected',
              );
              throw ValidationException(
                'Invalid assignment data structure',
                'assignments',
              );
            }

            // Create backup of existing data before overwriting
            try {
              final existingData = prefs.getString(_assignmentsKey);
              if (existingData != null && existingData.isNotEmpty) {
                final backupSuccess = await prefs.setString(
                  _assignmentsBackupKey,
                  existingData,
                );
                if (!backupSuccess) {
                  ErrorHandler.logError(
                    'saveAssignments',
                    'Failed to create backup',
                  );
                }
              }
            } catch (e) {
              ErrorHandler.logError('saveAssignments backup', e);
              // Continue anyway - backup failure shouldn't prevent save
            }

            // Serialize to JSON
            final jsonList = assignments.map((a) => a.toJson()).toList();
            final jsonString = jsonEncode(jsonList);

            // Check size limit
            if (jsonString.length > _maxJsonSize) {
              throw StorageException(
                'Data exceeds maximum size limit (${_maxJsonSize ~/ (1024 * 1024)}MB)',
                code: 'SIZE_LIMIT_EXCEEDED',
              );
            }

            // Save to storage
            final success = await prefs.setString(_assignmentsKey, jsonString);

            if (!success) {
              throw StorageException(
                'Failed to persist data to storage',
                code: 'WRITE_FAILED',
              );
            }

            // Update data version
            await prefs.setInt(_dataVersionKey, _currentDataVersion);
            print('Successfully saved ${assignments.length} assignments');

            return true;
          },
          context: 'StorageService.saveAssignments',
          defaultValue: false,
        ) ??
        false;
  }

  /// Loads assignments from local storage with fallback to backup
  ///
  /// Attempts to load from primary storage, falls back to backup if corrupted
  /// Performs data validation and integrity checks
  Future<List<Assignment>> loadAssignments() async {
    return await ErrorHandler.execute(
          operation: () async {
            final prefs = await SharedPreferences.getInstance();
            final jsonString = prefs.getString(_assignmentsKey);

            if (jsonString == null || jsonString.isEmpty) {
              print('No assignments data found in storage');
              return <Assignment>[];
            }

            // Try to parse primary data
            try {
              final jsonList = jsonDecode(jsonString) as List<dynamic>;
              final assignments = jsonList
                  .map(
                    (json) => Assignment.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();

              // Validate loaded data
              if (_validateAssignments(assignments)) {
                print('Successfully loaded ${assignments.length} assignments');
                return assignments;
              } else {
                ErrorHandler.logError(
                  'loadAssignments',
                  'Loaded assignments failed validation',
                );
                throw DataCorruptionException(
                  'Assignment data validation failed',
                );
              }
            } catch (e) {
              ErrorHandler.logError('loadAssignments parse', e);
              // Try loading from backup
              return await _loadAssignmentsFromBackup(prefs);
            }
          },
          context: 'StorageService.loadAssignments',
          defaultValue: <Assignment>[],
        ) ??
        <Assignment>[];
  }

  /// Attempts to load assignments from backup storage
  Future<List<Assignment>> _loadAssignmentsFromBackup(
    SharedPreferences prefs,
  ) async {
    print('Attempting to restore assignments from backup...');
    try {
      final backupString = prefs.getString(_assignmentsBackupKey);

      if (backupString == null || backupString.isEmpty) {
        print('No backup data available');
        return [];
      }

      final jsonList = jsonDecode(backupString) as List<dynamic>;
      final assignments = jsonList
          .map((json) => Assignment.fromJson(json as Map<String, dynamic>))
          .toList();

      if (_validateAssignments(assignments)) {
        print(
          'Successfully restored ${assignments.length} assignments from backup',
        );
        // Restore backup to primary storage
        await prefs.setString(_assignmentsKey, backupString);
        return assignments;
      }
    } catch (e) {
      print('Error loading assignments from backup: $e');
    }

    return [];
  }

  /// Validates assignments data integrity
  bool _validateAssignments(List<Assignment> assignments) {
    if (assignments.isEmpty) return true;

    try {
      for (final assignment in assignments) {
        // Check required fields
        if (assignment.id.isEmpty || assignment.title.isEmpty) {
          print('Invalid assignment: missing required fields');
          return false;
        }

        // Check date validity
        if (assignment.dueDate.isBefore(DateTime(2000))) {
          print('Invalid assignment: invalid date');
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error validating assignments: $e');
      return false;
    }
  }

  /// Saves a list of academic sessions to local storage with backup
  Future<bool> saveSessions(List<AcademicSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Validate input data
      if (!_validateSessions(sessions)) {
        print('Warning: Invalid sessions data detected, skipping save');
        return false;
      }

      // Create backup of existing data
      final existingData = prefs.getString(_sessionsKey);
      if (existingData != null && existingData.isNotEmpty) {
        await prefs.setString(_sessionsBackupKey, existingData);
      }

      // Serialize to JSON
      final jsonList = sessions.map((s) => s.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      // Check size limit
      if (jsonString.length > _maxJsonSize) {
        print('Error: Sessions data exceeds maximum size limit');
        return false;
      }

      // Save to storage
      final success = await prefs.setString(_sessionsKey, jsonString);

      if (success) {
        // Update data version
        await prefs.setInt(_dataVersionKey, _currentDataVersion);
      }

      return success;
    } catch (e) {
      print('Error saving sessions: $e');
      return false;
    }
  }

  /// Loads academic sessions from local storage with fallback to backup
  Future<List<AcademicSession>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_sessionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('No sessions data found in storage');
        return [];
      }

      // Try to parse primary data
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        final sessions = jsonList
            .map(
              (json) => AcademicSession.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // Validate loaded data
        if (_validateSessions(sessions)) {
          print('Successfully loaded ${sessions.length} sessions');
          return sessions;
        } else {
          print('Warning: Loaded sessions failed validation');
        }
      } catch (e) {
        print('Error parsing sessions JSON: $e');
        // Try loading from backup
        return await _loadSessionsFromBackup(prefs);
      }

      return [];
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  /// Attempts to load sessions from backup storage
  Future<List<AcademicSession>> _loadSessionsFromBackup(
    SharedPreferences prefs,
  ) async {
    print('Attempting to restore sessions from backup...');
    try {
      final backupString = prefs.getString(_sessionsBackupKey);

      if (backupString == null || backupString.isEmpty) {
        print('No backup data available');
        return [];
      }

      final jsonList = jsonDecode(backupString) as List<dynamic>;
      final sessions = jsonList
          .map((json) => AcademicSession.fromJson(json as Map<String, dynamic>))
          .toList();

      if (_validateSessions(sessions)) {
        print('Successfully restored ${sessions.length} sessions from backup');
        // Restore backup to primary storage
        await prefs.setString(_sessionsKey, backupString);
        return sessions;
      }
    } catch (e) {
      print('Error loading sessions from backup: $e');
    }

    return [];
  }

  /// Validates sessions data integrity
  bool _validateSessions(List<AcademicSession> sessions) {
    if (sessions.isEmpty) return true;

    try {
      for (final session in sessions) {
        // Check required fields
        if (session.id.isEmpty || session.title.isEmpty) {
          print('Invalid session: missing required fields');
          return false;
        }

        // Check date validity
        if (session.date.isBefore(DateTime(2000))) {
          print('Invalid session: invalid date');
          return false;
        }

        // Check time validity
        if (session.startTime.hour > 23 || session.endTime.hour > 23) {
          print('Invalid session: invalid time');
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error validating sessions: $e');
      return false;
    }
  }

  /// Gets the current data version
  Future<int> getDataVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_dataVersionKey) ?? 0;
    } catch (e) {
      print('Error getting data version: $e');
      return 0;
    }
  }

  /// Checks if backup data exists
  Future<bool> hasBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAssignmentsBackup = prefs.containsKey(_assignmentsBackupKey);
      final hasSessionsBackup = prefs.containsKey(_sessionsBackupKey);
      return hasAssignmentsBackup || hasSessionsBackup;
    } catch (e) {
      print('Error checking backup: $e');
      return false;
    }
  }

  /// Restores data from backup (manual restore)
  Future<bool> restoreFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool restored = false;

      // Restore assignments backup
      final assignmentsBackup = prefs.getString(_assignmentsBackupKey);
      if (assignmentsBackup != null) {
        await prefs.setString(_assignmentsKey, assignmentsBackup);
        restored = true;
        print('Restored assignments from backup');
      }

      // Restore sessions backup
      final sessionsBackup = prefs.getString(_sessionsBackupKey);
      if (sessionsBackup != null) {
        await prefs.setString(_sessionsKey, sessionsBackup);
        restored = true;
        print('Restored sessions from backup');
      }

      return restored;
    } catch (e) {
      print('Error restoring from backup: $e');
      return false;
    }
  }

  /// Exports all data as a JSON string (for backup/sharing)
  Future<String?> exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignments = prefs.getString(_assignmentsKey) ?? '[]';
      final sessions = prefs.getString(_sessionsKey) ?? '[]';

      final exportData = {
        'version': _currentDataVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'assignments': jsonDecode(assignments),
        'sessions': jsonDecode(sessions),
      };

      return jsonEncode(exportData);
    } catch (e) {
      print('Error exporting data: $e');
      return null;
    }
  }

  /// Imports data from a JSON string (for restore/sharing)
  Future<bool> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      // Validate import data structure
      if (!data.containsKey('assignments') || !data.containsKey('sessions')) {
        print('Error: Invalid import data structure');
        return false;
      }

      // Import assignments
      final assignmentsJson = jsonEncode(data['assignments']);
      await prefs.setString(_assignmentsKey, assignmentsJson);

      // Import sessions
      final sessionsJson = jsonEncode(data['sessions']);
      await prefs.setString(_sessionsKey, sessionsJson);

      // Update version
      await prefs.setInt(
        _dataVersionKey,
        data['version'] ?? _currentDataVersion,
      );

      print('Successfully imported data');
      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }

  /// Clears all stored data including backups
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_assignmentsKey);
      await prefs.remove(_sessionsKey);
      await prefs.remove(_assignmentsBackupKey);
      await prefs.remove(_sessionsBackupKey);
      await prefs.remove(_dataVersionKey);
      print('All data cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  /// Gets storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final assignmentsJson = prefs.getString(_assignmentsKey);
      final sessionsJson = prefs.getString(_sessionsKey);
      final assignmentsBackup = prefs.getString(_assignmentsBackupKey);
      final sessionsBackup = prefs.getString(_sessionsBackupKey);

      return {
        'assignmentsSize': assignmentsJson?.length ?? 0,
        'sessionsSize': sessionsJson?.length ?? 0,
        'assignmentsBackupSize': assignmentsBackup?.length ?? 0,
        'sessionsBackupSize': sessionsBackup?.length ?? 0,
        'totalSize':
            (assignmentsJson?.length ?? 0) +
            (sessionsJson?.length ?? 0) +
            (assignmentsBackup?.length ?? 0) +
            (sessionsBackup?.length ?? 0),
        'hasBackup': (assignmentsBackup != null) || (sessionsBackup != null),
        'dataVersion': await getDataVersion(),
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {};
    }
  }
}
