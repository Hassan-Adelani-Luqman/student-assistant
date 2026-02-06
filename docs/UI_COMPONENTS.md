# UI Components and Utilities

This document provides an overview of the reusable UI components and utility functions available in the Student Assistant application.

## Widgets

### EmptyState (`lib/widgets/empty_state.dart`)
Displays a friendly empty state with an icon, message, and optional action button.

**Usage:**
```dart
EmptyState(
  icon: Icons.assignment_outlined,
  title: 'No Assignments Yet',
  message: 'Get started by creating your first assignment.',
  actionLabel: 'Create Assignment',
  onAction: () => _showAddAssignmentDialog(context),
)
```

### ErrorState (`lib/widgets/error_state.dart`)
Shows error messages with a retry option.

**Usage:**
```dart
ErrorState(
  message: 'Failed to load data. Please try again.',
  onRetry: () => _loadData(),
)
```

### ShimmerLoading (`lib/widgets/shimmer_loading.dart`)
Provides skeleton loading states with shimmer animation.

**Components:**
- `ShimmerLoading`: Wrapper that adds shimmer effect to child widgets
- `SkeletonCard`: Placeholder card for loading states
- `SkeletonLine`: Placeholder text line for loading states

**Usage:**
```dart
ShimmerLoading(
  isLoading: isDataLoading,
  child: SkeletonCard(height: 100),
)
```

### AnimatedProgressIndicator (`lib/widgets/animated_progress_indicator.dart`)
Circular progress indicator with smooth animations.

**Components:**
- `AnimatedProgressIndicator`: Animated circular progress with customizable colors
- `BrandedLoadingIndicator`: Simple loading spinner with app branding

**Usage:**
```dart
AnimatedProgressIndicator(
  value: 0.75, // 0.0 to 1.0
  color: AppTheme.successGreen,
  size: 180,
  strokeWidth: 12,
)
```

### AnimatedCard (`lib/widgets/animated_card.dart`)
Card that animates in with scale and fade effect.

**Usage:**
```dart
AnimatedCard(
  delay: 100, // Delay in milliseconds
  onTap: () => _handleTap(),
  child: YourCardContent(),
)
```

### AttendanceBadge (`lib/widgets/attendance_badge.dart`)
Floating badge that appears when attendance is below 75%.

**Features:**
- Auto-hides when attendance is healthy
- Tap to navigate to attendance screen
- Gradient background with warning colors

## Utilities

### UI Helpers (`lib/utils/ui_helpers.dart`)
Common UI feedback functions.

**Functions:**
- `showSuccessSnackBar(context, message)`: Green success notification
- `showErrorSnackBar(context, message)`: Red error notification
- `showInfoSnackBar(context, message)`: Blue information notification
- `showWarningSnackBar(context, message)`: Yellow warning notification
- `showLoadingDialog(context, {message})`: Modal loading dialog
- `showConfirmationDialog(...)`: Confirmation dialog with customizable options

**Usage:**
```dart
// Success notification
showSuccessSnackBar(context, 'Assignment created successfully!');

// Confirmation
final confirmed = await showConfirmationDialog(
  context: context,
  title: 'Delete Assignment',
  message: 'Are you sure you want to delete this assignment?',
  isDangerous: true,
);
if (confirmed) {
  // Perform deletion
}
```

### Responsive (`lib/utils/responsive.dart`)
Responsive design utilities for different screen sizes.

**Breakpoints:**
- Mobile: < 600px
- Tablet: 600px - 1200px
- Desktop: >= 1200px

**Functions:**
- `Responsive.isMobile(context)`: Check if screen is mobile
- `Responsive.isTablet(context)`: Check if screen is tablet
- `Responsive.isDesktop(context)`: Check if screen is desktop
- `Responsive.value<T>(context, {mobile, tablet, desktop})`: Get responsive value
- `Responsive.padding(context)`: Get responsive padding
- `Responsive.cardWidth(context)`: Get responsive card width
- `Responsive.gridColumns(context)`: Get column count for grid
- `Responsive.fontSize(context, baseSize)`: Scale font size

**Usage:**
```dart
// Get different values for different screen sizes
final fontSize = Responsive.value(
  context,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);

// Responsive padding
Padding(
  padding: Responsive.padding(context),
  child: YourWidget(),
)
```

### Page Transitions (`lib/utils/page_transitions.dart`)
Custom page route animations.

**Routes:**
- `SlidePageRoute`: Slide from right
- `FadePageRoute`: Fade transition
- `ScalePageRoute`: Scale and fade

**Usage:**
```dart
Navigator.of(context).push(
  SlidePageRoute(page: DetailScreen()),
);
```

## Design Patterns

### Animation Timing
- Card animations: 300-400ms
- Page transitions: 200-300ms
- Progress indicators: 1000ms for smooth value changes
- Shimmer loading: 1500ms cycle

### Color Usage
- Success: `AppTheme.successGreen`
- Error/Warning: `AppTheme.warningRed`
- Info: `AppTheme.darkBlue`
- Accent: `AppTheme.accentYellow`

### Spacing
- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

### Border Radius
- Small: 4px (text lines, chips)
- Medium: 8px (snackbars, buttons)
- Large: 12px (cards, dialogs)

## Best Practices

1. **Loading States**: Always use shimmer loading or skeleton screens during data fetch
2. **Empty States**: Provide helpful empty states with actions when possible
3. **Error Handling**: Show errors with retry options, not just messages
4. **Animations**: Keep animations subtle and performant (under 400ms)
5. **Feedback**: Provide immediate feedback for user actions (snackbars, animations)
6. **Responsive**: Test UI on different screen sizes
7. **Accessibility**: Ensure text contrast ratios meet WCAG standards
8. **Consistency**: Use theme colors and spacing constants throughout

## Testing Checklist

- [ ] Test empty states for all lists
- [ ] Verify loading animations work smoothly
- [ ] Test error states with retry functionality
- [ ] Verify responsive layout on mobile, tablet, desktop
- [ ] Test page transitions are smooth
- [ ] Verify all snackbars display correctly
- [ ] Test confirmation dialogs work as expected
- [ ] Verify animations don't cause jank or lag
