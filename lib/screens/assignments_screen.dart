import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assignment_provider.dart';
import '../models/assignment.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../utils/validation_helper.dart';
import '../utils/ui_helpers.dart';

/// Assignments screen - Manage all academic assignments
///
/// Features:
/// - View all assignments sorted by due date
/// - Filter by type (all, formative, summative)
/// - Create new assignments
/// - Mark assignments as complete
/// - Edit and delete assignments
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Formative, 2: Summative

  @override
  void initState() {
    super.initState();
    // Set up error callback after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupErrorCallback();
    });
  }

  void _setupErrorCallback() {
    final assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );
    assignmentProvider.setErrorCallback((error) {
      if (mounted) {
        showErrorSnackBar(context, error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildFilterTab('All', 0),
                    const SizedBox(width: 24),
                    _buildFilterTab('Formative', 1),
                    const SizedBox(width: 24),
                    _buildFilterTab('Summative', 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<AssignmentProvider>(
        builder: (context, assignmentProvider, child) {
          final filteredAssignments = _getFilteredAssignments(
            assignmentProvider,
          );

          return Column(
            children: [
              // Create Assignment Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showAddAssignmentDialog(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Assignment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Assignments List
              Expanded(
                child: filteredAssignments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredAssignments.length,
                        itemBuilder: (context, index) {
                          final assignment = filteredAssignments[index];
                          return _buildAssignmentCard(
                            context,
                            assignment,
                            assignmentProvider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a filter tab
  Widget _buildFilterTab(String label, int index) {
    final isSelected = _selectedFilter == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: label.length * 8.0,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentYellow : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Gets filtered assignments based on selected filter
  List<Assignment> _getFilteredAssignments(AssignmentProvider provider) {
    final allAssignments = provider.assignments;

    switch (_selectedFilter) {
      case 1: // Formative
        return allAssignments
            .where((a) => a.priority.toLowerCase() != 'high')
            .toList();
      case 2: // Summative
        return allAssignments
            .where((a) => a.priority.toLowerCase() == 'high')
            .toList();
      default: // All
        return allAssignments;
    }
  }

  /// Builds an assignment card
  Widget _buildAssignmentCard(
    BuildContext context,
    Assignment assignment,
    AssignmentProvider provider,
  ) {
    final isOverdue = assignment.isOverdue;
    final priorityColor = AppTheme.getPriorityColor(assignment.priority);

    return Dismissible(
      key: Key(assignment.id),
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
              title: const Text('Delete Assignment'),
              content: const Text(
                'Are you sure you want to delete this assignment?',
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
        provider.deleteAssignment(assignment.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${assignment.title} deleted')));
      },
      child: InkWell(
        onTap: () => _showEditAssignmentDialog(context, assignment),
        onLongPress: () =>
            _showAssignmentOptionsMenu(context, assignment, provider),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: priorityColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Priority indicator dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.courseName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGray,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assignment.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              decoration: assignment.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppTheme.textGray,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                        if (isOverdue && !assignment.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentYellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Overdue',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Assignment Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: assignment.assignmentType == 'Summative'
                                ? AppTheme.warningRed.withValues(alpha: 0.15)
                                : AppTheme.successGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                assignment.assignmentType == 'Summative'
                                    ? Icons.school
                                    : Icons.psychology,
                                size: 12,
                                color: assignment.assignmentType == 'Summative'
                                    ? AppTheme.warningRed
                                    : AppTheme.successGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                assignment.assignmentType,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      assignment.assignmentType == 'Summative'
                                      ? AppTheme.warningRed
                                      : AppTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Due ${_formatDate(assignment.dueDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: assignment.isCompleted
                                  ? AppTheme.textGray
                                  : AppTheme.textGray,
                            ),
                          ),
                        ),
                        // Priority badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            assignment.priority,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (assignment.isCompleted) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppTheme.successGreen,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Action buttons column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: AppTheme.accentYellow,
                      size: 20,
                    ),
                    onPressed: () =>
                        _showEditAssignmentDialog(context, assignment),
                    tooltip: 'Edit',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  // Delete button
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: AppTheme.warningRed,
                      size: 20,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Assignment'),
                            content: const Text(
                              'Are you sure you want to delete this assignment?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: AppTheme.warningRed),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm == true) {
                        provider.deleteAssignment(assignment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${assignment.title} deleted'),
                            ),
                          );
                        }
                      }
                    },
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Checkbox for completion
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: assignment.isCompleted,
                  onChanged: (value) {
                    provider.toggleComplete(assignment.id);
                  },
                  activeColor: AppTheme.successGreen,
                  checkColor: AppTheme.cardWhite,
                  fillColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.successGreen;
                    }
                    return AppTheme.textGray;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows options menu for assignment (Edit/Delete/Toggle Complete)
  void _showAssignmentOptionsMenu(
    BuildContext context,
    Assignment assignment,
    AssignmentProvider provider,
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
              ListTile(
                leading: Icon(
                  assignment.isCompleted
                      ? Icons.cancel_outlined
                      : Icons.check_circle_outline,
                  color: AppTheme.accentYellow,
                ),
                title: Text(
                  assignment.isCompleted
                      ? 'Mark as Incomplete'
                      : 'Mark as Complete',
                  style: const TextStyle(color: AppTheme.textLight),
                ),
                onTap: () {
                  provider.toggleComplete(assignment.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        assignment.isCompleted
                            ? 'Marked as incomplete'
                            : 'Assignment completed!',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppTheme.accentYellow,
                ),
                title: const Text(
                  'Edit Assignment',
                  style: TextStyle(color: AppTheme.textLight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditAssignmentDialog(context, assignment);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.warningRed,
                ),
                title: const Text(
                  'Delete Assignment',
                  style: TextStyle(color: AppTheme.warningRed),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Assignment'),
                        content: const Text(
                          'Are you sure you want to delete this assignment?',
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
                    provider.deleteAssignment(assignment.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${assignment.title} deleted')),
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
    String title, message;

    if (_selectedFilter == 1) {
      title = 'No Formative Assignments';
      message = 'You don\'t have any formative assignments yet.';
    } else if (_selectedFilter == 2) {
      title = 'No Summative Assignments';
      message = 'You don\'t have any summative assignments yet.';
    } else {
      title = 'No Assignments Yet';
      message = 'Get started by creating your first assignment.';
    }

    return EmptyState(
      icon: Icons.assignment_outlined,
      title: title,
      message: message,
      actionLabel: 'Create Assignment',
      onAction: () => _showAddAssignmentDialog(context),
    );
  }

  /// Shows add assignment dialog
  void _showAddAssignmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentFormDialog(
        onSave:
            (
              title,
              dueDate,
              course,
              priority,
              assignmentType,
              collaborationType,
            ) async {
              final provider = Provider.of<AssignmentProvider>(
                context,
                listen: false,
              );
              final assignment = Assignment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                dueDate: dueDate,
                courseName: course,
                priority: priority,
                assignmentType: assignmentType,
                collaborationType: collaborationType,
              );
              await provider.addAssignment(assignment);
              if (context.mounted) {
                Navigator.pop(context);
                showSuccessSnackBar(context, 'Assignment created successfully');
              }
            },
      ),
    );
  }

  /// Shows edit assignment dialog
  void _showEditAssignmentDialog(BuildContext context, Assignment assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentFormDialog(
        assignment: assignment,
        onSave:
            (
              title,
              dueDate,
              course,
              priority,
              assignmentType,
              collaborationType,
            ) async {
              final provider = Provider.of<AssignmentProvider>(
                context,
                listen: false,
              );
              final updatedAssignment = assignment.copyWith(
                title: title,
                dueDate: dueDate,
                courseName: course,
                priority: priority,
                assignmentType: assignmentType,
                collaborationType: collaborationType,
              );
              await provider.updateAssignment(assignment.id, updatedAssignment);
              if (context.mounted) {
                Navigator.pop(context);
                showSuccessSnackBar(context, 'Assignment updated successfully');
              }
            },
      ),
    );
  }

  /// Formats a date to a readable string
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Assignment form dialog for creating/editing assignments
class AssignmentFormDialog extends StatefulWidget {
  final Assignment? assignment;
  final Function(
    String title,
    DateTime dueDate,
    String course,
    String priority,
    String assignmentType,
    String collaborationType,
  )
  onSave;

  const AssignmentFormDialog({
    super.key,
    this.assignment,
    required this.onSave,
  });

  @override
  State<AssignmentFormDialog> createState() => _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends State<AssignmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courseController;
  late DateTime _selectedDate;
  late String _selectedPriority;
  late String _selectedAssignmentType;
  late String _selectedCollaborationType;
  String? _dateError;

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _assignmentTypes = ['Formative', 'Summative'];
  final List<String> _collaborationTypes = ['Individual', 'Group'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.assignment?.title ?? '',
    );
    _courseController = TextEditingController(
      text: widget.assignment?.courseName ?? '',
    );
    _selectedDate =
        widget.assignment?.dueDate ??
        DateTime.now().add(const Duration(days: 7));
    _selectedPriority = widget.assignment?.priority ?? 'Medium';
    _selectedAssignmentType = widget.assignment?.assignmentType ?? 'Formative';
    _selectedCollaborationType =
        widget.assignment?.collaborationType ?? 'Individual';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
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
                      widget.assignment == null
                          ? 'New Assignment'
                          : 'Edit Assignment',
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
                    labelText: 'Assignment Title *',
                    hintText: 'Enter assignment title (3-100 characters)',
                    helperText: 'Required field',
                    prefixIcon: Icon(
                      Icons.assignment,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                  maxLength: 100,
                  textCapitalization: TextCapitalization.sentences,
                  validator: ValidationHelper.validateAssignmentTitle,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),

                // Course Field
                TextFormField(
                  controller: _courseController,
                  style: const TextStyle(color: AppTheme.textLight),
                  decoration: const InputDecoration(
                    labelText: 'Course Name *',
                    hintText: 'e.g., Introduction to Programming',
                    helperText: 'Required field (2-50 characters)',
                    prefixIcon: Icon(Icons.book, color: AppTheme.accentYellow),
                  ),
                  maxLength: 50,
                  textCapitalization: TextCapitalization.words,
                  validator: ValidationHelper.validateCourseName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),

                // Due Date Picker
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate.isBefore(now)
                          ? now
                          : _selectedDate,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                      helpText: 'Select due date',
                      errorFormatText: 'Invalid date format',
                      fieldLabelText: 'Due date',
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                        _dateError = ValidationHelper.validateAssignmentDueDate(
                          date,
                        );
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date *',
                      helperText: 'Must be today or in the future',
                      errorText: _dateError,
                      prefixIcon: const Icon(
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

                // Assignment Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedAssignmentType,
                  style: const TextStyle(color: AppTheme.textLight),
                  dropdownColor: AppTheme.darkBlue,
                  decoration: const InputDecoration(
                    labelText: 'Assignment Type *',
                    helperText: 'Formative (practice) or Summative (graded)',
                    prefixIcon: Icon(
                      Icons.category,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                  items: _assignmentTypes.map((type) {
                    IconData icon;
                    Color color;
                    if (type == 'Formative') {
                      icon = Icons.psychology;
                      color = AppTheme.successGreen;
                    } else {
                      icon = Icons.school;
                      color = AppTheme.warningRed;
                    }
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: color),
                          const SizedBox(width: 8),
                          Text(
                            type,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAssignmentType = value;
                      });
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select assignment type' : null,
                ),
                const SizedBox(height: 16),

                // Priority Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  style: const TextStyle(color: AppTheme.textLight),
                  dropdownColor: AppTheme.darkBlue,
                  decoration: const InputDecoration(
                    labelText: 'Priority *',
                    helperText: 'Importance level (High/Medium/Low)',
                    prefixIcon: Icon(Icons.flag, color: AppTheme.accentYellow),
                  ),
                  items: _priorities.map((priority) {
                    IconData icon;
                    Color color;
                    switch (priority) {
                      case 'High':
                        icon = Icons.warning;
                        color = AppTheme.warningRed;
                        break;
                      case 'Medium':
                        icon = Icons.info;
                        color = AppTheme.accentYellow;
                        break;
                      default:
                        icon = Icons.check_circle;
                        color = AppTheme.successGreen;
                    }
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 8),
                          Text(priority),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select a priority' : null,
                ),
                const SizedBox(height: 16),

                // Collaboration Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCollaborationType,
                  style: const TextStyle(color: AppTheme.textLight),
                  dropdownColor: AppTheme.darkBlue,
                  decoration: const InputDecoration(
                    labelText: 'Collaboration Type *',
                    helperText: 'Individual or Group assignment',
                    prefixIcon: Icon(
                      Icons.people,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                  items: _collaborationTypes.map((type) {
                    IconData icon;
                    Color color;
                    if (type == 'Individual') {
                      icon = Icons.person;
                      color = AppTheme.successGreen;
                    } else {
                      icon = Icons.group;
                      color = AppTheme.accentYellow;
                    }
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: color),
                          const SizedBox(width: 8),
                          Text(
                            type,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCollaborationType = value;
                      });
                    }
                  },
                  validator: (value) => value == null
                      ? 'Please select a collaboration type'
                      : null,
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate date
                      final dateError =
                          ValidationHelper.validateAssignmentDueDate(
                            _selectedDate,
                          );
                      setState(() {
                        _dateError = dateError;
                      });

                      // Validate form
                      if (_formKey.currentState!.validate() &&
                          dateError == null) {
                        widget.onSave(
                          _titleController.text.trim(),
                          _selectedDate,
                          _courseController.text.trim(),
                          _selectedPriority,
                          _selectedAssignmentType,
                          _selectedCollaborationType,
                        );
                      } else {
                        showErrorSnackBar(
                          context,
                          'Please fix the errors before saving',
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.assignment == null ? Icons.add : Icons.check,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.assignment == null
                                ? 'Create Assignment'
                                : 'Update Assignment',
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
