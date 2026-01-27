# Blood Pressure App - Architecture Documentation

## Overview

This app follows a **Provider-based MVVM architecture** with clear separation of concerns and loose coupling between components.

## Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Splash     │  │  Dashboard   │  │  Add Reading │  │
│  │   Screen     │  │    Screen    │  │    Screen    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │  Analytics   │  │   BP Card    │                    │
│  │   Screen     │  │   Widget     │                    │
│  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   STATE MANAGEMENT                       │
│                  ┌──────────────┐                        │
│                  │  BPProvider  │                        │
│                  │ (ChangeNotifier)                      │
│                  └──────────────┘                        │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC                        │
│                  ┌──────────────┐                        │
│                  │   Storage    │                        │
│                  │   Service    │                        │
│                  └──────────────┘                        │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   BPRecord   │  │ SharedPrefs  │  │ Localization │  │
│  │    Model     │  │   (Local)    │  │    Utils     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Component Responsibilities

### 1. Presentation Layer (Screens & Widgets)

**Responsibility**: Display UI and handle user interactions

- **SplashScreen**: Animated loading screen
- **DashboardScreen**: Main screen showing BP records list
- **AddReadingScreen**: Form to input new BP readings
- **AnalysisScreen**: Charts and analytics visualization
- **BPCard**: Reusable widget for displaying individual BP records

**Dependencies**:

- Consumes `BPProvider` via `Consumer<BPProvider>`
- Uses `AppStrings` for localization
- Uses `AppTheme` for styling

**Key Principle**: Screens are **stateless consumers** - they don't manage business logic

### 2. State Management (Provider)

**Responsibility**: Manage app state and coordinate data flow

**BPProvider**:

```dart
class BPProvider extends ChangeNotifier {
  - List<BPRecord> _records
  - bool _isLoading
  - String _languageCode

  + loadRecords()
  + addRecord(systolic, diastolic)
  + toggleLanguage()
  + getRecordsForPeriod(period)
  + getAverages(records)
}
```

**Dependencies**:

- Injects `StorageService`
- Notifies UI on state changes

**Key Principle**: Single source of truth for app state

### 3. Business Logic (Services)

**Responsibility**: Handle data operations and business rules

**StorageService**:

```dart
class StorageService {
  + getRecords() → Future<List<BPRecord>>
  + saveRecord(record) → Future<void>
  + clearRecords() → Future<void>
}
```

**Dependencies**:

- Uses `SharedPreferences` for persistence
- Uses `BPRecord` model for data structure

**Key Principle**: Isolated, testable business logic

### 4. Data Layer (Models & Utils)

**Responsibility**: Define data structures and utilities

**BPRecord Model**:

```dart
class BPRecord {
  - String id
  - int systolic
  - int diastolic
  - DateTime timestamp

  + toMap()
  + fromMap()
  + toJson()
  + fromJson()
}
```

**AppStrings (Localization)**:

```dart
class AppStrings {
  static get(key, languageCode) → String
}
```

**AppTheme**:

```dart
class AppTheme {
  static ThemeData lightTheme
}
```

## Data Flow

### Adding a New BP Record

```
User Input (AddReadingScreen)
        │
        ▼
Validate Form
        │
        ▼
provider.addRecord(systolic, diastolic)
        │
        ▼
BPProvider creates BPRecord
        │
        ▼
storageService.saveRecord(record)
        │
        ▼
SharedPreferences saves JSON
        │
        ▼
provider.loadRecords()
        │
        ▼
notifyListeners()
        │
        ▼
UI Rebuilds (Dashboard updates)
```

### Loading Records on App Start

```
App Launch
        │
        ▼
SplashScreen (3 seconds)
        │
        ▼
Navigate to Dashboard
        │
        ▼
BPProvider() constructor
        │
        ▼
loadRecords()
        │
        ▼
storageService.getRecords()
        │
        ▼
SharedPreferences reads JSON
        │
        ▼
Parse to List<BPRecord>
        │
        ▼
Sort by timestamp (latest first)
        │
        ▼
notifyListeners()
        │
        ▼
Dashboard displays records
```

## Loose Coupling Strategies

### 1. Dependency Injection

```dart
class BPProvider {
  final StorageService _storageService = StorageService();
  // Can be easily swapped for testing
}
```

### 2. Provider Pattern

```dart
// Screens don't create providers, they consume them
Consumer<BPProvider>(
  builder: (context, provider, child) {
    // Use provider data
  }
)
```

### 3. Model Separation

```dart
// BPRecord is independent of storage mechanism
// Can switch from SharedPreferences to SQLite without changing model
```

### 4. Service Abstraction

```dart
// StorageService can be replaced with:
// - CloudStorageService
// - DatabaseService
// - MockStorageService (for testing)
```

## Testing Strategy

### Unit Tests

- Test `BPRecord` serialization/deserialization
- Test `StorageService` CRUD operations
- Test `BPProvider` state management logic

### Widget Tests

- Test `BPCard` rendering
- Test form validation in `AddReadingScreen`
- Test navigation flows

### Integration Tests

- Test complete user flows
- Test data persistence across app restarts

## Benefits of This Architecture

✅ **Maintainability**: Clear separation makes code easy to understand and modify  
✅ **Testability**: Each layer can be tested independently  
✅ **Scalability**: Easy to add new features without breaking existing code  
✅ **Reusability**: Components can be reused across the app  
✅ **Flexibility**: Easy to swap implementations (e.g., change storage backend)

## Future Refactoring Opportunities

1. **Abstract Storage Interface**

   ```dart
   abstract class IStorageService {
     Future<List<BPRecord>> getRecords();
     Future<void> saveRecord(BPRecord record);
   }
   ```

2. **Repository Pattern**

   ```dart
   class BPRepository {
     final IStorageService _storage;
     BPRepository(this._storage);
   }
   ```

3. **Use Cases / Interactors**

   ```dart
   class AddBPRecordUseCase {
     final BPRepository _repository;
     Future<void> execute(int systolic, int diastolic);
   }
   ```

4. **Dependency Injection Container**
   ```dart
   // Use get_it or provider for DI
   final getIt = GetIt.instance;
   getIt.registerSingleton<IStorageService>(StorageService());
   ```
