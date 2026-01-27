# Failed Tests Report

The following tests failed during the execution of `flutter test`.

## File: `test/screens/dashboard_screen_memory_test.dart`

**Error:** `pumpAndSettle timed out`

This error usually indicates that there is an infinite animation or an active timer that prevents the widget tester from settling.

**Failed Test Cases:**
1. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - Initial State should display memory usage card title`
2. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - Display Values should display 0% memory usage correctly`
3. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - Boundary Value Testing should show "Moderate" at exact boundary 74%`
4. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - Boundary Value Testing should show "High" at exact boundary 75%`
5. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - Boundary Value Testing should show "High" at exact boundary 89%`
6. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - UI Components should clamp circular progress value to 0.0 for negative values`
7. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - Status Color Testing should show success color for Optimized status (< 25%)`
8. `DashboardScreen - Memory Usage Display Tests Memory Usage Card - Status Color Testing should show success color for Normal status (25-49%)`

*(Note: Additional tests in this file likely failed with the same error due to the persistent timeout issue.)*
