# Custom Project Rules

## Widget Architecture

### Stateless Widgets
* **Prefer StatelessWidget:** Always try to create stateless widget classes first. Only use StatefulWidget when state management is absolutely necessary.
* **State Management:** When state is needed, prefer using providers, Riverpod, or other state management solutions over StatefulWidget when possible.
* **Widget Size Limit:** Each widget class should not exceed 100 lines of code. If a widget grows beyond this limit, break it down into smaller, composable widgets.

### Widget Parameters
* **Parameter Limit:** If a widget needs more than 3 parameters, create a model class to encapsulate them instead of passing individual parameters.
* **Model Types:** Use two types of models:
  * **UI Models (`ui_model`):** For widget configuration, styling, and presentation logic. Place in `lib/models/ui_model/` directory.
  * **Data Models (`data_model`):** For business logic, API responses, and domain entities. Place in `lib/models/data_model/` directory.

## Code Organization

### File Structure
* **One Widget Per File:** Each widget should be in its own file, named using `snake_case` matching the widget class name.
* **Widget Extraction:** Extract reusable UI components into separate widget files in `lib/widgets/` directory.
* **Feature-Based Organization:** Group related widgets, models, and services by feature in `lib/features/` when appropriate.

### Model Organization
* **UI Models Location:** `lib/models/ui_model/` - Contains models used for UI configuration, widget parameters, and presentation state.
* **Data Models Location:** `lib/models/data_model/` - Contains models for business logic, API data, and domain entities.
* **Model Naming:** UI models should end with `Config`, `Props`, or `Params` (e.g., `CardConfig`, `ButtonProps`). Data models should use descriptive domain names (e.g., `DeviceVital`, `SensorReading`).

## Code Quality Standards

### Function and Method Guidelines
* **Single Responsibility:** Each function should do one thing well. If a function does multiple things, split it.
* **Function Length:** Keep functions under 30 lines. If longer, extract logic into helper functions or separate methods.
* **Method Extraction:** Extract complex expressions or repeated patterns into named methods or variables.

### Widget Composition
* **Small, Focused Widgets:** Create small, focused widgets that do one thing well. Compose complex UIs from these smaller widgets.
* **Private Widgets:** Use private widgets (prefixed with `_`) for internal composition within a file.
* **Reusable Components:** Identify and extract commonly used patterns into reusable widget components.

### State Management
* **Provider Pattern:** Use Provider or Riverpod for app-wide state management.
* **Local State:** Use StatefulWidget only for truly local, ephemeral UI state that doesn't need to be shared.
* **State Separation:** Keep UI state separate from business logic state.

## Best Practices

### Performance
* **const Constructors:** Use `const` constructors wherever possible to improve performance.
* **Widget Rebuilds:** Minimize unnecessary widget rebuilds by using `const` widgets and proper state management.
* **ListView Optimization:** Use `ListView.builder` for long lists instead of `ListView` with children.

### Error Handling
* **Null Safety:** Always handle null cases explicitly. Use null-aware operators (`?.`, `??`) appropriately.
* **Error Boundaries:** Implement proper error handling for async operations and user inputs.
* **Validation:** Validate data at model boundaries (UI models and data models).

### Testing
* **Widget Testing:** Write widget tests for all custom widgets, especially reusable components.
* **Unit Testing:** Test business logic in data models and services separately from UI.
* **Test Organization:** Mirror the `lib/` structure in `test/` directory.

### Documentation
* **Public APIs:** Document all public widget constructors, especially those with model parameters.
* **Complex Logic:** Add comments for complex widget composition or business logic.
* **Model Documentation:** Document model classes, their purpose, and when to use UI models vs data models.

## Refactoring Guidelines

### When to Refactor
* **Widget Exceeds 100 Lines:** Break down into smaller widgets.
* **More Than 3 Parameters:** Create a UI model to encapsulate parameters.
* **Repeated Patterns:** Extract into reusable widgets or helper functions.
* **Complex Build Method:** Extract parts of the build method into separate widget methods or private widgets.

### Refactoring Patterns
* **Extract Widget:** Move complex widget trees into separate widget classes.
* **Extract Method:** Move complex logic into named methods.
* **Create Model:** Group related parameters into model classes.
* **Split Screen:** Break large screens into smaller, focused widget components.

## Naming Conventions

### Widgets
* **Widget Classes:** Use `PascalCase` (e.g., `DeviceCard`, `VitalMonitorWidget`).
* **Widget Files:** Use `snake_case` matching the class name (e.g., `device_card.dart`, `vital_monitor_widget.dart`).

### Models
* **UI Models:** Use descriptive names ending with `Config`, `Props`, or `Params` (e.g., `CardConfig`, `DashboardProps`).
* **Data Models:** Use domain-specific names (e.g., `DeviceVital`, `SensorData`, `HealthMetric`).

### Directories
* **UI Models:** `lib/models/ui_model/`
* **Data Models:** `lib/models/data_model/`
* **Reusable Widgets:** `lib/widgets/`
* **Feature Widgets:** `lib/features/<feature_name>/widgets/`
