# Student Academic Platform - Implementation Plan

## Project Overview
A mobile application to help ALU students manage academic responsibilities, track assignments, monitor schedules, and maintain attendance records.

---

## Phase 1: Project Setup & Architecture (Day 1)

### 1.1 Project Structure Setup
Create the following folder structure:
```
lib/
├── main.dart
├── models/
│   ├── assignment.dart
│   ├── academic_session.dart
│   └── attendance_record.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── assignments_screen.dart
│   └── schedule_screen.dart
├── widgets/
│   ├── assignment_card.dart
│   ├── session_card.dart
│   ├── attendance_indicator.dart
│   └── custom_bottom_nav.dart
├── services/
│   ├── storage_service.dart
│   └── attendance_calculator.dart
├── providers/
│   ├── assignment_provider.dart
│   ├── session_provider.dart
│   └── attendance_provider.dart
└── theme/
    └── app_theme.dart
```

### 1.2 Dependencies to Add
Update `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0          # State management
  intl: ^0.18.0             # Date formatting
  shared_preferences: ^2.0.0 # Data persistence
  table_calendar: ^3.0.0    # Calendar widget
  fl_chart: ^0.60.0         # Optional: for charts
```

Run: `flutter pub get`

---

## Phase 2: Data Models & State Management (Day 1-2)

### 2.1 Create Data Models

**Assignment Model** (`lib/models/assignment.dart`):
```dart
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final String priority; // High/Medium/Low
  bool isCompleted;
  
  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority = 'Medium',
    this.isCompleted = false,
  });
  
  // Add toJson() and fromJson() for persistence
}
```

**Academic Session Model** (`lib/models/academic_session.dart`):
```dart
class AcademicSession {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String sessionType; // Class/Mastery/Study Group/PSL
  bool? attended; // null = not recorded, true/false = present/absent
  
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
  
  // Add toJson() and fromJson()
}
```

**Attendance Record Model** (`lib/models/attendance_record.dart`):
```dart
class AttendanceRecord {
  final int totalSessions;
  final int attendedSessions;
  
  double get percentage => 
    totalSessions > 0 ? (attendedSessions / totalSessions) * 100 : 0;
  
  bool get isAtRisk => percentage < 75;
  
  AttendanceRecord({
    required this.totalSessions,
    required this.attendedSessions,
  });
}
```

### 2.2 Setup Providers (State Management)

**Assignment Provider** (`lib/providers/assignment_provider.dart`):
- List of assignments
- Methods: addAssignment(), deleteAssignment(), toggleComplete(), updateAssignment()
- Method: getUpcomingAssignments(7 days)
- Load/Save to storage

**Session Provider** (`lib/providers/session_provider.dart`):
- List of sessions
- Methods: addSession(), deleteSession(), updateSession(), recordAttendance()
- Method: getTodaySessions()
- Method: getWeeklySessions()
- Load/Save to storage

**Attendance Provider** (`lib/providers/attendance_provider.dart`):
- Calculate attendance from sessions
- Provide AttendanceRecord
- Alert system for <75%

---

## Phase 3: Theme & UI Setup (Day 2)

### 3.1 Define App Theme (`lib/theme/app_theme.dart`)

Based on the screenshots, implement:
```dart
class AppTheme {
  static const Color navyBlue = Color(0xFF0A1128);
  static const Color darkBlue = Color(0xFF1A2238);
  static const Color accentYellow = Color(0xFFF4C430);
  static const Color warningRed = Color(0xFFEF4444);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: navyBlue,
      scaffoldBackgroundColor: navyBlue,
      colorScheme: ColorScheme.dark(
        primary: accentYellow,
        secondary: accentYellow,
        surface: darkBlue,
        error: warningRed,
      ),
      // Define text themes, button themes, etc.
    );
  }
}
```

---

## Phase 4: Navigation Structure (Day 2-3)

### 4.1 Bottom Navigation Bar
Create main.dart with:
- Scaffold with BottomNavigationBar
- 3 tabs: Dashboard, Assignments, Schedule
- Icons matching the screenshot design
- State to switch between screens

**Main Navigation** (`lib/main.dart`):
```dart
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    AssignmentsScreen(),
    ScheduleScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assignments'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
        ],
      ),
    );
  }
}
```

---

## Phase 5: Dashboard Screen Implementation (Day 3-4)

### 5.1 Dashboard Layout Structure

**DashboardScreen** (`lib/screens/dashboard_screen.dart`):

Components to build:
1. **Header Section**
   - User greeting
   - Current date
   - Current academic week (calculate from semester start)

2. **Attendance Warning Card** (conditional)
   - Show red warning if attendance < 75%
   - Display current percentage
   - Icon: Warning triangle

3. **Stats Cards** (3 cards in a row)
   - Active Progress (count of incomplete assignments)
   - Code Factors (custom metric or sessions this week)
   - Upcoming Agents (assignments due in 7 days)

4. **Today's Classes Section**
   - List of sessions scheduled for today
   - Each session card shows: title, time, type
   - Tap to view details

5. **Upcoming Assignments Section**
   - Assignments due in next 7 days
   - Sorted by due date
   - Show due date, title, course

### 5.2 Widgets to Create
- `AttendanceWarningCard` - Red card with warning
- `StatCard` - Small card showing number + label
- `SessionCard` - Card for displaying session info
- `AssignmentPreviewCard` - Mini assignment card for dashboard

---

## Phase 6: Assignment Management Screen (Day 4-5)

### 6.1 Assignments Screen Layout

**AssignmentsScreen** (`lib/screens/assignments_screen.dart`):

Components:
1. **Tab Bar** (optional)
   - All assignments
   - Formative
   - Summative

2. **Floating Action Button**
   - "+" button to add new assignment
   - Yellow accent color

3. **Assignment List**
   - Sorted by due date
   - Each card shows:
     - Assignment title
     - Course name
     - Due date
     - Priority indicator (color-coded)
     - Checkbox for completion
   - Swipe actions: Edit, Delete

### 6.2 Add/Edit Assignment Form

Create modal bottom sheet or new screen with:
- Text field: Assignment title (required)
- Date picker: Due date
- Text field: Course name
- Dropdown: Priority (High/Medium/Low)
- Save button (yellow)

**Validation:**
- Title cannot be empty
- Due date must be selected
- Course name required

### 6.3 Assignment Card Widget
- Visual priority indicator (colored dot or border)
- Strike-through text when completed
- Tap to edit
- Long press menu: Edit/Delete

---

## Phase 7: Schedule Screen Implementation (Day 5-6)

### 7.1 Schedule Screen Layout

**ScheduleScreen** (`lib/screens/schedule_screen.dart`):

Components:
1. **Calendar Widget** (using table_calendar)
   - Month view
   - Highlight days with sessions
   - Tap day to filter sessions

2. **Session Type Filter** (optional)
   - Chips or buttons: All, Class, Mastery, Study Group, PSL

3. **Sessions List**
   - Grouped by date
   - Each session card shows:
     - Session title
     - Time range (start - end)
     - Location
     - Session type
     - Attendance toggle (Present/Absent checkbox)

4. **Floating Action Button**
   - "+" to add new session

### 7.2 Add/Edit Session Form

Form fields:
- Text field: Session title (required)
- Date picker: Date
- Time picker: Start time
- Time picker: End time
- Text field: Location (optional)
- Dropdown: Session type
- Save button

**Validation:**
- Title required
- Date required
- Start time < End time
- Session type selected

### 7.3 Session Card Widget
- Color-coded by session type
- Show attendance status (icon or color)
- Tap to edit/record attendance
- Swipe to delete

---

## Phase 8: Attendance Tracking System (Day 6-7)

### 8.1 Attendance Calculator Service

**AttendanceCalculator** (`lib/services/attendance_calculator.dart`):

Methods:
```dart
class AttendanceCalculator {
  static AttendanceRecord calculate(List<AcademicSession> sessions) {
    // Filter sessions that have attendance recorded
    final recordedSessions = sessions.where((s) => s.attended != null).toList();
    final attended = recordedSessions.where((s) => s.attended == true).length;
    
    return AttendanceRecord(
      totalSessions: recordedSessions.length,
      attendedSessions: attended,
    );
  }
  
  static bool shouldShowWarning(double percentage) {
    return percentage < 75;
  }
}
```

### 8.2 Attendance Display Widgets

**AttendanceIndicator** (`lib/widgets/attendance_indicator.dart`):
- Circular percentage indicator
- Color changes based on percentage:
  - Green: >= 85%
  - Yellow: 75-84%
  - Red: < 75%

### 8.3 Integration
- Dashboard shows current attendance percentage
- Warning card appears when < 75%
- Schedule screen allows recording attendance
- Real-time updates when attendance is recorded

---

## Phase 9: Data Persistence (Day 7-8)

### 9.1 Storage Service Setup

**StorageService** (`lib/services/storage_service.dart`):

Using SharedPreferences:
```dart
class StorageService {
  static const String ASSIGNMENTS_KEY = 'assignments';
  static const String SESSIONS_KEY = 'sessions';
  
  Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    final json = assignments.map((a) => a.toJson()).toList();
    await prefs.setString(ASSIGNMENTS_KEY, jsonEncode(json));
  }
  
  Future<List<Assignment>> loadAssignments() async {
    // Load and parse JSON
  }
  
  // Similar for sessions
}
```

### 9.2 Provider Integration
- Call save methods after add/edit/delete operations
- Load data in initState or provider constructor
- Handle loading states

### 9.3 Alternative: SQLite (Advanced)
If using SQLite:
- Add `sqflite` dependency
- Create database helper class
- Define table schemas
- Implement CRUD operations

---

## Phase 10: Polish & Testing (Day 8-9)

### 10.1 UI Refinements
- [ ] Ensure all colors match ALU branding
- [ ] Add loading indicators
- [ ] Add empty state messages ("No assignments yet")
- [ ] Smooth animations and transitions
- [ ] Responsive padding and margins
- [ ] Test on different screen sizes

### 10.2 Input Validation
- [ ] All required fields validated
- [ ] Date validations (future dates for assignments)
- [ ] Time validations (end > start)
- [ ] Error messages displayed clearly

### 10.3 Error Handling
- [ ] Handle storage errors gracefully
- [ ] Network errors (if applicable)
- [ ] Display user-friendly error messages

### 10.4 Testing Checklist
- [ ] Create assignment → verify saved → restart app → verify persisted
- [ ] Mark assignment complete → check dashboard count updates
- [ ] Add session → record attendance → verify percentage calculation
- [ ] Delete items → verify removed from all views
- [ ] Edit items → verify changes reflected
- [ ] Test with 0 items, 1 item, many items
- [ ] Test attendance at exactly 75%, above, below
- [ ] Test assignments due today, tomorrow, next week

---

## Phase 11: Optimization & Code Quality (Day 9-10)

### 11.1 Code Organization
- [ ] Separate UI from logic
- [ ] Use meaningful variable/function names
- [ ] Add comments explaining complex logic
- [ ] Remove unused imports/code
- [ ] Format code consistently

### 11.2 Documentation
Create README.md:
- Project description
- Features list
- Setup instructions
- Dependencies
- Architecture overview
- Screenshots

### 11.3 Git Best Practices
- Commit frequently with clear messages
- Each team member works on feature branches
- Meaningful commit messages: "Add assignment creation form"
- Avoid committing all at once

---

## Implementation Timeline (10 Days)

### Day 1: Foundation
- Project structure
- Dependencies
- Data models
- Basic theme setup

### Day 2: Core Setup
- Providers setup
- Navigation structure
- Theme refinement

### Day 3-4: Dashboard
- Dashboard layout
- Attendance warning
- Stats cards
- Today's sessions
- Upcoming assignments

### Day 5: Assignments
- Assignment screen
- Add/edit form
- List view with actions
- Mark complete functionality

### Day 6: Schedule
- Calendar integration
- Session list
- Add/edit session form
- Session type filtering

### Day 7: Attendance
- Attendance calculation
- Recording attendance
- Indicators and warnings
- Integration across screens

### Day 8: Persistence
- Storage service
- Save/load functionality
- Data migration handling

### Day 9: Testing & Polish
- Comprehensive testing
- UI refinements
- Bug fixes
- Performance optimization

### Day 10: Documentation & Submission
- README documentation
- Code comments
- Demo video preparation
- Final testing

---

## Key Features Checklist

### Dashboard ✓
- [x] Today's date display
- [x] Current academic week
- [x] Today's sessions list
- [x] Assignments due in 7 days
- [x] Overall attendance percentage
- [x] Visual warning when attendance < 75%
- [x] Count of pending assignments

### Assignment Management ✓
- [x] Create assignment (title, date, course, priority)
- [x] View all assignments sorted by date
- [x] Mark complete
- [x] Delete assignment
- [x] Edit assignment

### Session Scheduling ✓
- [x] Create session (title, date, start/end time, location, type)
- [x] Weekly schedule view
- [x] Record attendance (Present/Absent)
- [x] Delete session
- [x] Edit session

### Attendance Tracking ✓
- [x] Auto-calculate percentage
- [x] Display metrics on dashboard
- [x] Alert when < 75%
- [x] Maintain history

### Technical Requirements ✓
- [x] BottomNavigationBar with 3 tabs
- [x] Data persistence (SharedPreferences)
- [x] ALU color palette
- [x] Input validation
- [x] Responsive design
- [x] No overflow errors

---

## Team Distribution Suggestions

### Developer 1: Data & State Management
- Models
- Providers
- Storage service
- Attendance calculator

### Developer 2: Dashboard & Navigation
- Main navigation
- Dashboard screen
- Theme setup
- Shared widgets

### Developer 3: Assignments Feature
- Assignments screen
- Assignment form
- Assignment cards
- List management

### Developer 4: Schedule Feature
- Schedule screen
- Calendar integration
- Session form
- Session cards

**Note:** All developers should:
- Work on feature branches
- Commit regularly
- Review each other's code
- Test their features thoroughly

---

## Common Pitfalls to Avoid

1. **Not handling edge cases**
   - Empty lists
   - Null values
   - Invalid dates

2. **Poor state management**
   - Not calling notifyListeners()
   - Not using Provider correctly
   - State not persisting

3. **UI overflow errors**
   - Use Expanded, Flexible widgets
   - SingleChildScrollView for long content
   - Test on small screens

4. **Date/time issues**
   - Time zones
   - Date formatting
   - Parsing errors

5. **Not testing persistence**
   - Always test app restart
   - Verify data survives
   - Handle migration

6. **Inconsistent styling**
   - Use theme colors
   - Consistent spacing
   - Uniform card designs

---

## Resources

### Flutter Documentation
- [Provider package](https://pub.dev/packages/provider)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Table Calendar](https://pub.dev/packages/table_calendar)
- [Intl package](https://pub.dev/packages/intl)

### Design
- Material Design guidelines
- Color picker for ALU colors
- Icon resources

### Testing
- Flutter widget testing
- Integration testing
- Manual testing checklist

---

## Demo Video Script Template

1. **Introduction (30s)**
   - "Hello, I'm [name] and I'll walk you through our Student Academic Platform"
   - Show app running on device/emulator

2. **Architecture Explanation (1 min)**
   - Show folder structure
   - Explain separation of concerns
   - Point out models, providers, screens

3. **Dashboard Feature (2 min)**
   - Show main.dart navigation code
   - Explain how dashboard fetches data
   - Demo adding a session, show it appears on dashboard
   - Show attendance calculation code

4. **Assignments Feature (2 min)**
   - Walk through assignment model
   - Show assignment provider code
   - Demo creating assignment
   - Explain validation logic
   - Show persistence code

5. **Schedule Feature (2 min)**
   - Show session model
   - Demo adding session
   - Explain time validation
   - Record attendance
   - Show percentage update

6. **Data Persistence (1 min)**
   - Show storage service code
   - Demo: close app, reopen, data persists
   - Explain toJson/fromJson

7. **Conclusion (30s)**
   - Summarize features
   - Show code quality (comments, structure)
   - Thank viewers

---

## Final Submission Checklist

- [ ] All features working
- [ ] Data persists after app restart
- [ ] No overflow errors
- [ ] Follows ALU color scheme
- [ ] Code well-organized and commented
- [ ] README.md complete
- [ ] All team members have commits
- [ ] Demo video recorded (shows code + running app)
- [ ] Contribution tracker filled
- [ ] PDF write-up completed
- [ ] GitHub repo link ready
- [ ] File named: GroupName_AssignmentName.pdf

---

## Success Metrics

**Exemplary Project:**
- Clean, modular code structure
- Comprehensive comments
- All features fully implemented
- Detailed demo explaining every line
- Perfect persistence
- Beautiful UI matching design
- No bugs or crashes

**Target:** 27-30 points
