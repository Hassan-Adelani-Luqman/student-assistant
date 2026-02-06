# Phase 10.4: Quick Testing Checklist ✅

**App Running:** ✅ YES  
**Clean State:** ⏳ In Progress  

---

## Core User Story Tests (From Requirements)

### ✅ 1. Create Assignment → Verify Saved → Restart → Verify Persisted
- [ ] Create "Test Assignment 1"
- [ ] See it in list
- [ ] Press `q` in terminal, then `flutter run -d linux`
- [ ] Still there after restart
- **Result:** _____

### ✅ 2. Mark Assignment Complete → Check Dashboard Count Updates
- [ ] Check box on assignment
- [ ] Go to Dashboard immediately
- [ ] Count decreased
- [ ] Restart app
- [ ] Still marked complete
- **Result:** _____

### ✅ 3. Add Session → Record Attendance → Verify Percentage Calculation
- [ ] Create session
- [ ] Mark "Present"
- [ ] Dashboard shows 100%
- [ ] Add 3 more sessions: 2 Present, 1 Absent
- [ ] Dashboard shows 75% (3/4)
- [ ] Color = Yellow
- **Result:** _____

### ✅ 4. Delete Items → Verify Removed from All Views
- [ ] Delete assignment
- [ ] Dashboard count updates
- [ ] Not in Assignments list
- [ ] Restart app
- [ ] Still deleted
- **Result:** _____

### ✅ 5. Edit Items → Verify Changes Reflected
- [ ] Edit assignment title
- [ ] Change due date
- [ ] See changes in list
- [ ] See changes on Dashboard
- [ ] Restart app
- [ ] Changes persisted
- **Result:** _____

### ✅ 6. Test with 0 Items, 1 Item, Many Items
- **0 Items:**
  - [ ] Empty states show
  - [ ] No crashes
  
- **1 Item:**
  - [ ] Single item displays correctly
  - [ ] No plural errors
  
- **Many Items (15+ assignments, 20+ sessions):**
  - [ ] Smooth scrolling
  - [ ] Fast save/load
  - [ ] All data persists
  
- **Result:** _____

### ✅ 7. Test Attendance at Exactly 75%, Above, Below
- **Exactly 75%:**
  - [ ] 3 Present, 1 Absent = 75%
  - [ ] Yellow indicator
  
- **Above 75% (80%):**
  - [ ] 4 Present, 1 Absent = 80%
  - [ ] Green indicator
  
- **Below 75% (67%):**
  - [ ] 4 Present, 2 Absent = 66.67%
  - [ ] Red indicator
  
- **Result:** _____

### ✅ 8. Test Assignments Due Today, Tomorrow, Next Week
- **Due Today:**
  - [ ] Red color
  - [ ] "Due Today" label
  
- **Due Tomorrow:**
  - [ ] Yellow/orange color
  - [ ] "1 day" countdown
  
- **Due Next Week:**
  - [ ] Neutral color
  - [ ] Correct days shown
  
- **Result:** _____

---

## Bonus Tests

### ✅ 9. Data Validation
- [ ] Empty title blocked
- [ ] Empty course blocked
- [ ] Invalid times prevented
- **Result:** _____

### ✅ 10. Multi-Screen Consistency
- [ ] Create on Assignments → Shows on Dashboard
- [ ] Edit anywhere → Updates everywhere
- [ ] Delete anywhere → Removed everywhere
- **Result:** _____

---

## Pass/Fail Summary

**Tests Passed:** __ / 10  
**Tests Failed:** __ / 10  
**Critical Bugs:** __ (list below)  

**Bugs Found:**
1. 
2. 
3. 

---

## Final Status

- [ ] All 8 required tests passed
- [ ] No critical bugs
- [ ] Data persistence works perfectly
- [ ] Dashboard always accurate
- [ ] Attendance calculations correct
- [ ] UI smooth and responsive

**Phase 10.4 Complete:** ✅ YES / ❌ NO  
**Ready for Production:** ✅ YES / ❌ NO  

---

## Quick Commands Reference

**In Terminal:**
- `r` - Hot reload (quick refresh)
- `R` - Hot restart (full restart, keeps app open)
- `q` - Quit app (for testing persistence)
- `flutter run -d linux` - Relaunch app

**App Navigation:**
- Dashboard - Main screen with stats
- Assignments - Tap to see list
- Schedule - Calendar and sessions
- "+" button - Create new item

---

**Start Testing Now!** 🚀

Follow the detailed guide in **PHASE_10_4_MANUAL_TESTING_GUIDE.md** for step-by-step instructions.
