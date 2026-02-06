import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/session_provider.dart';
import '../models/academic_session.dart';
import '../theme/app_theme.dart';
import '../utils/validation_helper.dart';
import '../utils/ui_helpers.dart';

/// Schedule screen - Manage academic sessions and calendar
///
/// Features:
/// - Calendar view with session highlights
/// - Weekly schedule view
/// - Create new sessions
/// - Record attendance
/// - Edit and delete sessions
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _selectedSessionType = 'All';

  final List<String> _sessionTypes = [
    'All',
    'Class',
    'Mastery Session',
    'Study Group',
    'PSL Meeting',
  ];

  @override
  void initState() {
    super.initState();
    // Load data after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );

    // Set up error callback
    sessionProvider.setErrorCallback((error) {
      if (mounted) {
        showErrorSnackBar(context, error);
      }
    });

    await sessionProvider.loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Consumer<SessionProvider>(
        builder: (context, sessionProvider, child) {
          return Column(
            children: [
              // Calendar Widget
              _buildCalendar(sessionProvider),

              // Session Type Filter
              _buildSessionTypeFilter(),

              // Sessions List
              Expanded(child: _buildSessionsList(sessionProvider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the calendar widget
  Widget _buildCalendar(SessionProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: (day) {
          return provider.getSessionsForDate(day);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: AppTheme.textLight),
          defaultTextStyle: const TextStyle(color: AppTheme.textLight),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.accentYellow,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: AppTheme.textDark),
          todayDecoration: BoxDecoration(
            color: AppTheme.accentYellow.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppTheme.textLight),
          markerDecoration: const BoxDecoration(
            color: AppTheme.successGreen,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: AppTheme.textLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.textLight),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppTheme.textLight,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: AppTheme.textGray),
          weekendStyle: TextStyle(color: AppTheme.textGray),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  /// Builds session type filter chips
  Widget _buildSessionTypeFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sessionTypes.length,
        itemBuilder: (context, index) {
          final type = _sessionTypes[index];
          final isSelected = _selectedSessionType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSessionType = type;
                });
              },
              backgroundColor: AppTheme.darkBlue,
              selectedColor: AppTheme.accentYellow,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.textDark : AppTheme.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              checkmarkColor: AppTheme.textDark,
            ),
          );
        },
      ),
    );
  }

  /// Builds the sessions list
  Widget _buildSessionsList(SessionProvider provider) {
    final sessionsForDay = provider.getSessionsForDate(_selectedDay);
    final filteredSessions = _selectedSessionType == 'All'
        ? sessionsForDay
        : sessionsForDay
              .where((s) => s.sessionType == _selectedSessionType)
              .toList();

    if (filteredSessions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSessions.length,
        itemBuilder: (context, index) {
          final session = filteredSessions[index];
          return _buildSessionCard(context, session, provider);
        },
      ),
    );
  }

  /// Builds a session card
  Widget _buildSessionCard(
    BuildContext context,
    AcademicSession session,
    SessionProvider provider,
  ) {
    final sessionColor = AppTheme.getSessionTypeColor(session.sessionType);
    final isPast = session.isPast;

    return Dismissible(
      key: Key(session.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.warningRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: AppTheme.textLight),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Session'),
              content: const Text(
                'Are you sure you want to delete this session?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppTheme.warningRed),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        provider.deleteSession(session.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${session.title} deleted')));
      },
      child: InkWell(
        onTap: () => _showEditSessionDialog(context, session),
        onLongPress: () => _showSessionOptionsMenu(context, session, provider),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sessionColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Session type color indicator
              Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                  color: sessionColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.sessionType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sessionColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          session.timeRange,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGray,
                          ),
                        ),
                      ],
                    ),
                    if (session.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.textGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              session.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Attendance indicator
              if (isPast)
                _buildAttendanceToggle(session, provider)
              else
                const Icon(Icons.chevron_right, color: AppTheme.textGray),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds attendance toggle button
  Widget _buildAttendanceToggle(
    AcademicSession session,
    SessionProvider provider,
  ) {
    if (session.attended == null) {
      return IconButton(
        icon: const Icon(
          Icons.check_box_outline_blank,
          color: AppTheme.textGray,
        ),
        onPressed: () => _showAttendanceDialog(session, provider),
      );
    } else if (session.attended!) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.successGreen.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: AppTheme.successGreen, size: 20),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.warningRed.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: AppTheme.warningRed, size: 20),
      );
    }
  }

  /// Shows attendance recording dialog
  void _showAttendanceDialog(
    AcademicSession session,
    SessionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Record Attendance'),
          content: Text('Did you attend "${session.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                provider.recordAttendance(session.id, false);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as Absent')),
                );
              },
              child: const Text(
                'Absent',
                style: TextStyle(color: AppTheme.warningRed),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.recordAttendance(session.id, true);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as Present')),
                );
              },
              child: const Text(
                'Present',
                style: TextStyle(color: AppTheme.successGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows session options menu
  void _showSessionOptionsMenu(
    BuildContext context,
    AcademicSession session,
    SessionProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (session.isPast && session.attended == null)
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.accentYellow,
                  ),
                  title: const Text(
                    'Record Attendance',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAttendanceDialog(session, provider);
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppTheme.accentYellow,
                ),
                title: const Text(
                  'Edit Session',
                  style: TextStyle(color: AppTheme.textLight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditSessionDialog(context, session);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.warningRed,
                ),
                title: const Text(
                  'Delete Session',
                  style: TextStyle(color: AppTheme.warningRed),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Session'),
                        content: const Text(
                          'Are you sure you want to delete this session?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppTheme.warningRed),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true && context.mounted) {
                    provider.deleteSession(session.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${session.title} deleted')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Builds empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: AppTheme.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions scheduled',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textGray),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first session',
            style: TextStyle(color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }

  /// Shows add session dialog
  void _showAddSessionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionFormDialog(
        selectedDate: _selectedDay,
        onSave: (title, date, startTime, endTime, location, sessionType) async {
          final provider = Provider.of<SessionProvider>(context, listen: false);
          final session = AcademicSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            date: date,
            startTime: startTime,
            endTime: endTime,
            location: location,
            sessionType: sessionType,
          );
          await provider.addSession(session);
          if (context.mounted) {
            // Update selected day to show the newly added session
            setState(() {
              _selectedDay = date;
              _focusedDay = date;
            });
            Navigator.pop(context);
            showSuccessSnackBar(context, 'Session created successfully');
          }
        },
      ),
    );
  }

  /// Shows edit session dialog
  void _showEditSessionDialog(BuildContext context, AcademicSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionFormDialog(
        session: session,
        selectedDate: session.date,
        onSave: (title, date, startTime, endTime, location, sessionType) async {
          final provider = Provider.of<SessionProvider>(context, listen: false);
          final updatedSession = session.copyWith(
            title: title,
            date: date,
            startTime: startTime,
            endTime: endTime,
            location: location,
            sessionType: sessionType,
          );
          await provider.updateSession(session.id, updatedSession);
          if (context.mounted) {
            Navigator.pop(context);
            showSuccessSnackBar(context, 'Session updated successfully');
          }
        },
      ),
    );
  }
}

/// Session form dialog for creating/editing sessions
class SessionFormDialog extends StatefulWidget {
  final AcademicSession? session;
  final DateTime selectedDate;
  final Function(
    String title,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String location,
    String sessionType,
  )
  onSave;

  const SessionFormDialog({
    super.key,
    this.session,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedSessionType;
  String? _timeError;

  final List<String> _sessionTypes = [
    'Class',
    'Mastery Session',
    'Study Group',
    'PSL Meeting',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session?.title ?? '');
    _locationController = TextEditingController(
      text: widget.session?.location ?? '',
    );
    _selectedDate = widget.session?.date ?? widget.selectedDate;
    _startTime =
        widget.session?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.session?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _selectedSessionType = widget.session?.sessionType ?? 'Class';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.session == null ? 'New Session' : 'Edit Session',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textLight),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppTheme.textLight),
                  decoration: const InputDecoration(
                    labelText: 'Session Title *',
                    hintText: 'e.g., Introduction to Algorithms',
                    helperText: 'Required field (3-100 characters)',
                    prefixIcon: Icon(Icons.title, color: AppTheme.accentYellow),
                  ),
                  maxLength: 100,
                  textCapitalization: TextCapitalization.sentences,
                  validator: ValidationHelper.validateSessionTitle,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),

                // Session Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedSessionType,
                  style: const TextStyle(color: AppTheme.textLight),
                  dropdownColor: AppTheme.darkBlue,
                  decoration: const InputDecoration(
                    labelText: 'Session Type *',
                    helperText: 'Select the type of session',
                    prefixIcon: Icon(
                      Icons.category,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                  items: _sessionTypes.map((type) {
                    IconData icon;
                    switch (type) {
                      case 'Class':
                        icon = Icons.school;
                        break;
                      case 'Mastery Session':
                        icon = Icons.psychology;
                        break;
                      case 'Study Group':
                        icon = Icons.groups;
                        break;
                      default:
                        icon = Icons.meeting_room;
                    }
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(icon, size: 18, color: AppTheme.accentYellow),
                          const SizedBox(width: 8),
                          Text(type),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSessionType = value;
                      });
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select a session type' : null,
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      helpText: 'Select session date',
                      fieldLabelText: 'Session date',
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      helperText: 'Date of the session',
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: AppTheme.accentYellow,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                          style: const TextStyle(color: AppTheme.textLight),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.textGray,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Pickers Row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                                helpText: 'Select start time',
                              );
                              if (time != null) {
                                setState(() {
                                  _startTime = time;
                                  _timeError =
                                      ValidationHelper.validateMinDuration(
                                        _startTime,
                                        _endTime,
                                        15,
                                      );
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Time *',
                                prefixIcon: Icon(
                                  Icons.access_time,
                                  color: AppTheme.accentYellow,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startTime.format(context),
                                    style: const TextStyle(
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppTheme.textGray,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _endTime,
                                helpText: 'Select end time',
                              );
                              if (time != null) {
                                setState(() {
                                  _endTime = time;
                                  _timeError =
                                      ValidationHelper.validateMinDuration(
                                        _startTime,
                                        _endTime,
                                        15,
                                      );
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Time *',
                                prefixIcon: Icon(
                                  Icons.access_time_filled,
                                  color: AppTheme.accentYellow,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endTime.format(context),
                                    style: const TextStyle(
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppTheme.textGray,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_timeError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 8),
                        child: Text(
                          _timeError!,
                          style: const TextStyle(
                            color: AppTheme.warningRed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (_timeError == null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 8),
                        child: Text(
                          'End time must be after start time (min. 15 min)',
                          style: TextStyle(
                            color: AppTheme.textGray.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Field
                TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: AppTheme.textLight),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., Room 301, Library, Online',
                    helperText: 'Optional (max 100 characters)',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  validator: ValidationHelper.validateLocation,
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate time range
                      final timeError = ValidationHelper.validateMinDuration(
                        _startTime,
                        _endTime,
                        15,
                      );
                      setState(() {
                        _timeError = timeError;
                      });

                      // Validate form
                      if (_formKey.currentState!.validate() &&
                          timeError == null) {
                        widget.onSave(
                          _titleController.text.trim(),
                          _selectedDate,
                          _startTime,
                          _endTime,
                          _locationController.text.trim(),
                          _selectedSessionType,
                        );
                      } else {
                        showErrorSnackBar(
                          context,
                          timeError ?? 'Please fix the errors before saving',
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.session == null ? Icons.add : Icons.check,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.session == null
                                ? 'Create Session'
                                : 'Update Session',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
