# Blood Pressure Monitoring App

A modern, clean mobile application for tracking blood pressure readings with analytics. Built with Flutter for Android & iOS.

## Features

✅ **No Login Required** - All data stored locally on device  
✅ **Clean Medical UI** - Calming colors (blue/green/white) with rounded cards  
✅ **Bilingual Support** - English and Nepali language toggle  
✅ **Animated Splash Screen** - Beautiful loading animation  
✅ **Dashboard** - View all BP records sorted by latest first  
✅ **Add Data** - Simple form with validation for systolic/diastolic values  
✅ **Analytics** - Interactive line charts with week/month/year filters  
✅ **Color-Coded Values** - Visual indicators for BP ranges  
✅ **Lazy Loading** - Optimized performance for large datasets

## Architecture

The app follows a **loosely coupled, provider-based architecture**:

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── bp_record.dart        # Data model for BP readings
├── providers/
│   └── bp_provider.dart      # State management with ChangeNotifier
├── screens/
│   ├── splash_screen.dart    # Animated splash screen
│   ├── dashboard_screen.dart # Main home screen with records list
│   ├── add_reading_screen.dart # Form to add new BP reading
│   └── analysis_screen.dart  # Charts and analytics
├── services/
│   └── storage_service.dart  # Local storage using SharedPreferences
├── theme/
│   └── app_theme.dart        # Centralized theme configuration
├── utils/
│   └── localization.dart     # English/Nepali translations
└── widgets/
    └── bp_card.dart          # Reusable BP record card widget
```

## Design Principles

### Separation of Concerns

- **Models**: Pure data classes with JSON serialization
- **Services**: Business logic for storage operations
- **Providers**: State management and data flow
- **Screens**: UI presentation layer
- **Widgets**: Reusable UI components

### Loose Coupling

- Screens depend on providers, not services directly
- Services are injected into providers
- Widgets receive data via parameters
- No hardcoded dependencies

### Medical-Grade Design

- Soft color palette: `#4A90E2` (blue), `#50E3C2` (green), `#F5F7FA` (background)
- Clear typography using Google Fonts (Outfit)
- High readability with proper contrast
- Color-coded BP values:
  - **Normal**: Blue (Systolic <120, Diastolic <80)
  - **Elevated**: Orange (Systolic 120-139, Diastolic 80-89)
  - **High**: Red (Systolic ≥140, Diastolic ≥90)

## Screens

### 1. Splash Screen

- Animated logo with fade-in and scale effects
- 3-second display time
- Smooth transition to dashboard

### 2. Dashboard (Home)

- List of BP records as cards
- Latest readings shown first
- Bottom navigation: History | Add Data | Analytics
- Language toggle in app bar
- Empty state with helpful message

### 3. Add Data

- Clean form with two numeric inputs
- Validation: Systolic (70-200), Diastolic (40-130)
- Large, accessible input fields
- Success feedback with SnackBar

### 4. Analytics

- Period filters: Week, Month, Year
- Interactive line chart (fl_chart)
- Systolic (red) and Diastolic (blue) trends
- Average values displayed below chart
- Empty state for periods with no data

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  fl_chart: ^1.1.1 # Charts
  google_fonts: ^7.1.0 # Typography
  intl: ^0.20.2 # Date formatting
  shared_preferences: ^2.5.4 # Local storage
  provider: ^6.1.5 # State management
```

## Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## Data Storage

All BP records are stored locally using `SharedPreferences`:

- No internet connection required
- Data persists across app restarts
- Privacy-focused: data never leaves the device

## Localization

Toggle between English and Nepali using the language button in the app bar.

Supported strings:

- App title, screen names
- Form labels and buttons
- Chart labels and periods
- Validation messages

## Color Scheme

| Element      | Color                                                           | Hex       |
| ------------ | --------------------------------------------------------------- | --------- |
| Primary Blue | ![#4A90E2](https://via.placeholder.com/15/4A90E2/000000?text=+) | `#4A90E2` |
| Accent Green | ![#50E3C2](https://via.placeholder.com/15/50E3C2/000000?text=+) | `#50E3C2` |
| Soft Red     | ![#E57373](https://via.placeholder.com/15/E57373/000000?text=+) | `#E57373` |
| Background   | ![#F5F7FA](https://via.placeholder.com/15/F5F7FA/000000?text=+) | `#F5F7FA` |
| Text Dark    | ![#2C3E50](https://via.placeholder.com/15/2C3E50/000000?text=+) | `#2C3E50` |
| Text Light   | ![#95A5A6](https://via.placeholder.com/15/95A5A6/000000?text=+) | `#95A5A6` |

## Future Enhancements

- [ ] Export data to CSV/PDF
- [ ] Medication reminders
- [ ] Notes field for each reading
- [ ] Custom date range picker
- [ ] Dark mode support
- [ ] Backup to cloud (optional)

## License

This project is for educational and personal use.
