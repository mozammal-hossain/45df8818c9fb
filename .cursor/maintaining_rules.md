# Device Vital Monitor - Repository Maintaining Rules

## Project Overview
This is a Flutter application that monitors device sensor data (thermal state, battery level, and memory usage) and logs it to a backend service. The project includes:
- Flutter mobile application (Android/iOS)
- Backend API (Node.js or .NET)
- Native platform modules using MethodChannels
- Unit tests for backend and Flutter logic

## Core Principles

### 1. Native Platform Integration
- **CRITICAL**: Do NOT use 3rd-party packages (like `battery_plus`) for sensor data retrieval
- Must use Flutter MethodChannels to communicate with native code
- Android: Use Kotlin/Java with `PowerManager`, `BatteryManager`, and `ActivityManager`
- iOS: Use Swift/Objective-C with `ProcessInfo` and `UIDevice`
- Handle platform-specific errors gracefully (PlatformException handling)

### 2. Backend API Requirements
- Must persist data (survive restart) - use SQLite, JSON file with locking, or embedded DB
- Required endpoints:
  - `POST /api/vitals` - Accept vital logs with validation
  - `GET /api/vitals` - Return historical logs with pagination (`page`, `pageSize`; default `pageSize` 20, max 100). History screen uses scroll-to-load-more.
  - `GET /api/vitals/analytics` - Return rolling average and insights
- **Data Validation Rules:**
  - `thermal_value`: Must be 0-3 (reject otherwise)
  - `battery_level`: Must be 0-100 (reject otherwise)
  - `memory_usage`: Must be 0-100 (reject otherwise)
  - `timestamp`: Must be ISO8601, reject future timestamps
  - Reject missing required fields

### 3. Flutter Application Architecture
- Use state management (Bloc)
- Separate business logic from UI (Repository pattern)
- Keep code organized and testable
- **Screens:**
  - Dashboard: Real-time sensor readings + "Log Status" button
  - History: Display historical logs and analytics
- **Error Handling:**
  - Show visible errors (Snackbar/Dialog) for backend unreachable
  - Handle PlatformException from native code
  - Handle network timeouts gracefully
  - Consider all edge cases

### 4. Testing Requirements
- **Backend Unit Tests:**
  - Rolling average calculation logic
  - Data validation (reject invalid sensor values)
- **Flutter Unit Tests:**
  - Repository/Service layer logic
- Widget/integration tests are optional

### 5. Code Quality Standards
- Clean, readable code with proper separation of concerns
- Logical problem-solving approach
- Handle ambiguity with documented decisions
- Document all design decisions in DECISIONS.md
- Maintain ai_log.md with AI collaboration story

## File Structure Guidelines

### Required Files
- `README.md` - Setup instructions (must work on first try)
- `DECISIONS.md` - Document ambiguities, design decisions, assumptions, and questions
- `ai_log.md` - AI collaboration story (prompts, wins, failures, understanding)
- Source code for Flutter app
- Source code for Backend API
- Unit tests

### Flutter App Structure
```
lib/
  ├── main.dart
  ├── models/          # Data models
  ├── services/        # API services, native channel services
  ├── repositories/    # Business logic layer
  ├── providers/       # State management
  ├── screens/         # UI screens (Dashboard, History)
  └── widgets/         # Reusable widgets
```

### Backend Structure
```
backend/
  ├── src/
  │   ├── routes/      # API routes
  │   ├── controllers/ # Request handlers
  │   ├── models/      # Data models
  │   ├── services/    # Business logic (validation, analytics)
  │   └── storage/     # Persistence layer
  └── tests/           # Unit tests
```

## Development Rules

### When Adding Features
1. **Check Requirements First**: Ensure feature aligns with project brief
2. **Native Code**: Always use MethodChannels, never 3rd-party sensor packages
3. **Validation**: Implement validation for all sensor data inputs
4. **Error Handling**: Add appropriate error handling for all new features
5. **Tests**: Write unit tests for business logic
6. **Documentation**: Update README if setup changes

### When Modifying Code
1. **Preserve Architecture**: Maintain separation of concerns
2. **Update Tests**: Ensure tests still pass or update them
3. **Error Handling**: Don't remove error handling without replacement
4. **Validation**: Don't bypass validation rules
5. **Documentation**: Update relevant docs if behavior changes

### Code Review Checklist
- [ ] No 3rd-party sensor packages used
- [ ] MethodChannels properly implemented
- [ ] Data validation in place
- [ ] Error handling present
- [ ] Tests updated/passing
- [ ] README still accurate
- [ ] Code follows separation of concerns

## Platform Support
- **Minimum**: At least ONE platform (Android OR iOS) fully implemented
- **Bonus**: Both platforms implemented
- Clearly document which platform(s) are supported in README

## Error Handling Standards
- Backend unreachable → Show user-friendly error message
- PlatformException → Handle gracefully, show error to user
- Network timeout → Retry logic or clear error message
- Invalid sensor data → Reject with clear validation error
- Missing native API support → Return sensible defaults or errors

## Testing Standards
- All business logic must have unit tests
- Test data validation thoroughly
- Test edge cases (boundary values, null values, etc.)
- Tests should be independent and repeatable

## Documentation Standards
- README must have clear setup instructions
- Setup should work on first try
- DECISIONS.md must document:
  - At least 3 ambiguities identified
  - Design decisions with alternatives considered
  - Assumptions made
  - Questions that would be asked to PM
- ai_log.md must document AI usage (or explain why not used)

## Auto-Reject Criteria (Avoid These!)
- ❌ Using 3rd-party plugin for sensor data
- ❌ No MethodChannel implementation
- ❌ Backend doesn't persist data
- ❌ Missing ai_log.md
- ❌ Missing DECISIONS.md
- ❌ Setup instructions don't work

## Bonus Features (Optional)
If implementing bonus features:
- Auto-Logging: Background service (WorkManager/Background Fetch)
- Offline Support: Local storage with sync
- Both Platforms: Android AND iOS
- Advanced UI: Charts/graphs for trends

## Git Workflow
- Keep commits focused and meaningful
- Write clear commit messages
- Ensure code runs after each commit
- Don't commit broken tests

## Questions to Consider
When making decisions, document:
- What ambiguity did you identify?
- What options did you consider?
- What decision did you make and why?
- What trade-offs did you accept?
- What assumptions did you make?

---

**Remember**: This is a take-home assignment demonstrating full-stack mobile development skills. Focus on clean code, proper architecture, and handling edge cases gracefully.
