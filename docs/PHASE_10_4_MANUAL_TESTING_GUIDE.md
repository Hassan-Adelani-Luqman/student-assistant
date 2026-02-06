# Phase 10.4: Manual Testing Guide

## 🎯 Testing Session Started

**App Status:** ✅ RUNNING  
**Current Data:** 2 assignments, 0 sessions  
**Platform:** Linux  
**Time:** Started at 20:31

---

## 📋 Testing Instructions

### How to Use This Guide

1. **Follow Each Test Step-by-Step** - Complete one test before moving to the next
2. **Mark Checkboxes** - Check off each step as you complete it
3. **Record Results** - Note PASS/FAIL for each test in PHASE_10_4_TEST_RESULTS.md
4. **Document Issues** - If any test fails, document the bug clearly
5. **Restart When Needed** - Use `r` in terminal for hot reload, `R` for hot restart, `q` to quit

---

## 🔧 Pre-Test: Clear Existing Data

**Goal:** Start with clean slate

**Steps:**
1. In the running app, navigate to Dashboard
2. Go to Assignments screen
3. Delete the 2 existing assignments (swipe or tap delete)
4. Verify empty state shows
5. Go to Schedule screen
6. Verify empty state shows (0 sessions)
7. Return to Dashboard
8. Verify shows: 0 active assignments, 0 sessions, 0% attendance

**Expected Result:** Clean state with no data

**Once complete, move to Test Suite 1 below**

---

## Test Suite 1: Assignment Persistence ✅

### Test 1.1: Create Assignment → Verify Saved → Restart → Verify Persisted 🔴 CRITICAL

**Instructions:**

1. **Navigate to Assignments Screen**
   - [ ] Tap "Assignments" from Dashboard or bottom nav
   - [ ] Verify empty state shows

2. **Create New Assignment**
   - [ ] Tap the "+" (FAB) button
   - [ ] Fill in details:
     - Title: "Test Assignment 1"
     - Course: "Software Engineering"
     - Type: Select "Summative"
     - Due Date: Pick a date 3 days from today
     - Description: "This is a test assignment"
   - [ ] Tap "Save" button

3. **Verify Assignment Saved**
   - [ ] Assignment appears in the list
   - [ ] Title shows "Test Assignment 1"
   - [ ] Course shows "Software Engineering"
   - [ ] Due date is correct (3 days away)
   - [ ] Type badge shows "Summative"
   - [ ] Checkbox is unchecked (not complete)

4. **Check Dashboard Updates**
   - [ ] Navigate to Dashboard
   - [ ] Verify "Active Assignments" count = 1
   - [ ] Assignment appears in "Upcoming Assignments" section
   - [ ] Due date countdown is correct

5. **RESTART APP** (Critical Step!)
   - [ ] In terminal, press `q` to quit
   - [ ] Run: `flutter run -d linux`
   - [ ] Wait for app to launch
   - [ ] Observe terminal output: "Successfully loaded X assignments"

6. **Verify Persistence**
   - [ ] Dashboard shows 1 active assignment
   - [ ] Navigate to Assignments screen
   - [ ] "Test Assignment 1" still exists
   - [ ] All details match (title, course, due date, type)
   - [ ] Checkbox still unchecked

**Record Result:**
- ✅ PASS if all data persisted correctly
- ❌ FAIL if any data lost or incorrect
- Document in PHASE_10_4_TEST_RESULTS.md

---

### Test 1.2: Mark Assignment Complete → Check Dashboard Count Updates 🔴 CRITICAL

**Instructions:**

1. **Mark Assignment Complete**
   - [ ] In Assignments screen, find "Test Assignment 1"
   - [ ] Tap the checkbox to mark complete
   - [ ] Checkbox animates to checked state
   - [ ] Green checkmark visible

2. **Verify Dashboard Updates IMMEDIATELY**
   - [ ] Navigate to Dashboard (no need to refresh)
   - [ ] "Active Assignments" count should now = 0
   - [ ] Assignment should move to completed section or update status

3. **Test Toggle**
   - [ ] Go back to Assignments
   - [ ] Uncheck the assignment
   - [ ] Go to Dashboard
   - [ ] Count should be back to 1

4. **Mark Complete Again**
   - [ ] Return to Assignments
   - [ ] Check the assignment again
   - [ ] Dashboard count = 0

5. **Restart and Verify**
   - [ ] Restart app (q then flutter run)
   - [ ] Assignment should still be marked complete
   - [ ] Dashboard count still = 0

**Record Result:**
- ✅ PASS if counts update instantly and persist
- ❌ FAIL if count doesn't update or completion state lost

---

### Test 1.3: Edit Assignment → Verify Changes Reflected

**Instructions:**

1. **Edit the Assignment**
   - [ ] In Assignments list, tap on "Test Assignment 1"
   - [ ] Tap edit icon/button
   - [ ] Change title to: "Updated Test Assignment"
   - [ ] Change due date to tomorrow
   - [ ] Change type to "Formative"
   - [ ] Tap "Save"

2. **Verify in Assignments List**
   - [ ] Title shows "Updated Test Assignment"
   - [ ] Due date shows tomorrow
   - [ ] Type badge shows "Formative"

3. **Verify in Dashboard**
   - [ ] Navigate to Dashboard
   - [ ] Updated title visible
   - [ ] Due date shows "Tomorrow" or "1 day"
   - [ ] Type updated

4. **Restart and Verify**
   - [ ] Restart app
   - [ ] Edits still present everywhere

**Record Result:**
- ✅ PASS if edits reflected in all views and persist
- ❌ FAIL if edits lost or not shown everywhere

---

### Test 1.4: Delete Assignment → Verify Removed from All Views 🔴 CRITICAL

**Instructions:**

1. **Delete Assignment**
   - [ ] In Assignments screen, swipe/tap delete on assignment
   - [ ] Confirm deletion in dialog
   - [ ] Assignment disappears from list
   - [ ] Empty state appears

2. **Verify Dashboard Updated**
   - [ ] Navigate to Dashboard
   - [ ] Active assignments = 0
   - [ ] No assignments shown in upcoming section

3. **Restart and Verify Deletion Persisted**
   - [ ] Restart app
   - [ ] Dashboard still shows 0
   - [ ] Assignments screen shows empty state
   - [ ] Assignment did NOT reappear

**Record Result:**
- ✅ PASS if deleted from all views permanently
- ❌ FAIL if reappears after restart

---

## Test Suite 2: Session Persistence & Attendance ✅

### Test 2.1: Add Session → Record Attendance → Verify Percentage Calculation 🔴 CRITICAL

**Instructions:**

1. **Create First Session**
   - [ ] Navigate to Schedule screen
   - [ ] Tap "+" button
   - [ ] Fill in:
     - Title: "Software Engineering Class"
     - Type: "Class"
     - Date: Today
     - Start Time: 09:00
     - End Time: 11:00
   - [ ] Tap "Save"

2. **Record Attendance**
   - [ ] Tap on the created session
   - [ ] Find attendance section
   - [ ] Mark as "Present" (green checkmark)
   - [ ] Verify status updated

3. **Check Dashboard**
   - [ ] Navigate to Dashboard
   - [ ] "Sessions Attended" count = 1
   - [ ] Attendance percentage = 100%
   - [ ] Green color indicator (good attendance)

4. **Restart and Verify**
   - [ ] Restart app
   - [ ] Session still exists
   - [ ] Attendance still marked Present
   - [ ] Dashboard shows 100%

**Record Result:**
- ✅ PASS if session and attendance persist correctly
- ❌ FAIL if attendance lost or percentage wrong

---

### Test 2.2: Test Attendance at Exactly 75% (Threshold)

**Instructions:**

1. **Create 3 More Sessions** (Total = 4)
   - [ ] Session 2: "PSL Meeting" - Date: Yesterday
   - [ ] Session 3: "Study Group" - Date: 2 days ago
   - [ ] Session 4: "Mastery Session" - Date: 3 days ago

2. **Record Attendance**
   - [ ] Session 1 (Software Eng): Already Present ✅
   - [ ] Session 2 (PSL): Mark Present ✅
   - [ ] Session 3 (Study Group): Mark Present ✅
   - [ ] Session 4 (Mastery): Mark Absent ❌

3. **Verify Calculation: 3/4 = 75%**
   - [ ] Navigate to Dashboard
   - [ ] Attendance shows exactly 75%
   - [ ] Color indicator = Yellow (warning at threshold)
   - [ ] Count shows: 3 sessions attended

4. **Verify Math**: 3 Present ÷ 4 Total = 0.75 = 75% ✅

**Record Result:**
- ✅ PASS if exactly 75% and yellow indicator
- ❌ FAIL if percentage wrong or color incorrect

---

### Test 2.3: Test Attendance Above 75%

**Instructions:**

1. **Add One More Session** (Total = 5)
   - [ ] Create "Algorithm Workshop"
   - [ ] Date: 4 days ago
   - [ ] Mark as Present ✅

2. **Verify Calculation: 4/5 = 80%**
   - [ ] Dashboard shows 80%
   - [ ] Color indicator = Green (good attendance)
   - [ ] Count shows: 4 sessions attended

3. **Verify Math**: 4 Present ÷ 5 Total = 0.80 = 80% ✅

**Record Result:**
- ✅ PASS if 80% and green indicator
- ❌ FAIL if percentage wrong or color incorrect

---

### Test 2.4: Test Attendance Below 75%

**Instructions:**

1. **Add One More Session** (Total = 6)
   - [ ] Create "Team Meeting"
   - [ ] Date: 5 days ago
   - [ ] Mark as Absent ❌

2. **Verify Calculation: 4/6 = 66.67%**
   - [ ] Dashboard shows 66.67% (or 67%)
   - [ ] Color indicator = Red (poor attendance)
   - [ ] Count shows: 4 sessions attended out of 6

3. **Verify Math**: 4 Present ÷ 6 Total = 0.6667 = 66.67% ✅

**Record Result:**
- ✅ PASS if ~67% and red indicator
- ❌ FAIL if percentage wrong or color incorrect

---

## Test Suite 3: Edge Cases ✅

### Test 3.1: Test with 0 Items

**Instructions:**

1. **Delete All Data**
   - [ ] Delete all assignments (should be 0 already)
   - [ ] Delete all 6 sessions created

2. **Verify Empty States**
   - [ ] Dashboard: Shows 0/0, empty message
   - [ ] Assignments: Empty state widget visible, helpful message
   - [ ] Schedule: Empty state widget visible, helpful message
   - [ ] No crashes
   - [ ] "+" buttons still accessible

3. **Restart with Empty Data**
   - [ ] Restart app
   - [ ] Still shows empty states
   - [ ] No errors in terminal

**Record Result:**
- ✅ PASS if empty states helpful and no crashes
- ❌ FAIL if crashes or UI broken

---

### Test 3.2: Test with 1 Item

**Instructions:**

1. **Create Exactly 1 Assignment**
   - [ ] Title: "Single Assignment"
   - [ ] Due: Tomorrow

2. **Create Exactly 1 Session**
   - [ ] Title: "Single Session"
   - [ ] Mark Present

3. **Verify UI**
   - [ ] Dashboard shows 1/1
   - [ ] Attendance = 100%
   - [ ] No plural issues ("1 assignments" vs "1 assignment")
   - [ ] No layout overflow

**Record Result:**
- ✅ PASS if single items display correctly
- ❌ FAIL if UI issues or grammar errors

---

### Test 3.3: Test with Many Items (Performance)

**Instructions:**

1. **Create 15 Assignments Rapidly**
   - [ ] Create assignments with various due dates
   - [ ] Mix of formative and summative
   - [ ] Some marked complete, some not

2. **Create 20 Sessions**
   - [ ] Various types
   - [ ] Mix of present/absent

3. **Test Performance**
   - [ ] Scroll through lists smoothly (60 FPS)
   - [ ] No lag when marking complete
   - [ ] Dashboard calculations fast (< 1 second)
   - [ ] Save/load operations quick

4. **Restart and Verify**
   - [ ] All 15 assignments load
   - [ ] All 20 sessions load
   - [ ] Load time < 2 seconds
   - [ ] No data lost

**Record Result:**
- ✅ PASS if smooth with many items
- ❌ FAIL if laggy or data lost

---

## Test Suite 4: Due Date Scenarios ✅

### Test 4.1: Assignment Due Today

**Instructions:**

1. **Create Assignment Due Today**
   - [ ] Title: "Due Today Test"
   - [ ] Due Date: Select today's date

2. **Verify Display**
   - [ ] Shows "Due Today" label
   - [ ] Red color (urgent)
   - [ ] Appears at/near top of list

**Record Result:**
- ✅ PASS if correctly highlighted
- ❌ FAIL if not urgent or wrong label

---

### Test 4.2: Assignment Due Tomorrow

**Instructions:**

1. **Create Assignment Due Tomorrow**
   - [ ] Title: "Due Tomorrow Test"
   - [ ] Due Date: Tomorrow

2. **Verify Display**
   - [ ] Shows "Due Tomorrow" or "1 day"
   - [ ] Yellow/orange color
   - [ ] Below "due today" items

**Record Result:**
- ✅ PASS if correct countdown
- ❌ FAIL if wrong date/color

---

### Test 4.3: Assignment Due Next Week

**Instructions:**

1. **Create Assignment Due in 7 Days**
   - [ ] Title: "Due Next Week Test"
   - [ ] Due Date: 7 days from now

2. **Verify Display**
   - [ ] Shows "7 days" or specific date
   - [ ] Green/neutral color
   - [ ] Sorted after sooner items

**Record Result:**
- ✅ PASS if future items lower priority
- ❌ FAIL if sorting wrong

---

### Test 4.4: Overdue Assignment

**Instructions:**

1. **Create Overdue Assignment**
   - [ ] Title: "Overdue Test"
   - [ ] Due Date: Yesterday or earlier

2. **Verify Display**
   - [ ] Shows "Overdue" or "X days overdue"
   - [ ] Red color (most urgent)
   - [ ] At very top of list

**Record Result:**
- ✅ PASS if most urgent
- ❌ FAIL if not prioritized

---

## Test Suite 5: Data Validation ✅

### Test 5.1: Invalid Input Validation 🔴 CRITICAL

**Instructions:**

1. **Try Empty Title (Assignment)**
   - [ ] Tap "+" to create assignment
   - [ ] Leave title blank
   - [ ] Try to save
   - [ ] Should show error: "Title is required"
   - [ ] Save button disabled OR error shown

2. **Try Empty Course**
   - [ ] Leave course blank
   - [ ] Should show error

3. **Try Invalid Session Times**
   - [ ] Create session
   - [ ] Set end time BEFORE start time
   - [ ] Should prevent or show error

4. **Verify No Bad Data Saved**
   - [ ] Invalid inputs don't create items
   - [ ] Restart app
   - [ ] No corrupt data

**Record Result:**
- ✅ PASS if all validation works
- ❌ FAIL if bad data saved

---

## Test Suite 6: UI/UX Validation ✅

### Test 6.1: Animations Smooth

**Visual Check:**
- [ ] Page transitions smooth
- [ ] Cards animate on tap
- [ ] Progress bars animate
- [ ] Loading states show briefly
- [ ] No flickering

**Record Result:** ✅ PASS / ❌ FAIL

---

### Test 6.2: Responsive Layout

**Window Resize Test:**
- [ ] Resize window smaller
- [ ] Resize window larger
- [ ] No text overflow
- [ ] Buttons still accessible
- [ ] Lists scroll

**Record Result:** ✅ PASS / ❌ FAIL

---

### Test 6.3: Empty & Error States

**Visual Check:**
- [ ] Empty states have icons
- [ ] Messages helpful
- [ ] CTA buttons work
- [ ] ALU colors used
- [ ] Error states show red
- [ ] Recovery suggestions shown

**Record Result:** ✅ PASS / ❌ FAIL

---

## 🎯 Final Checklist

After completing all tests:

- [ ] All critical tests (🔴) passed
- [ ] Data persists across restarts
- [ ] Dashboard counts always accurate
- [ ] Attendance calculations correct
- [ ] No crashes in any scenario
- [ ] Validation prevents bad data
- [ ] Delete removes from all views
- [ ] Edits update everywhere
- [ ] UI smooth and responsive
- [ ] Error messages user-friendly

**If ALL checked:** Phase 10.4 COMPLETE ✅  
**If ANY failed:** Document bugs, fix, re-test

---

## 📊 Next Steps

1. Fill out PHASE_10_4_TEST_RESULTS.md with all results
2. Document any bugs found
3. Fix critical issues
4. Re-test failed scenarios
5. Take screenshots for documentation
6. Prepare final demo

---

**Happy Testing!** 🧪✨
