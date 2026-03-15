# HeartSync 🫀

A premium, minimalist mobile application for tracking heart health and blood pressure with sophisticated analytics. Built with Flutter, featuring medical-grade aesthetics and a privacy-first approach.

## 📥 Download & Install

**Get the latest version for Android:**

[**Download HeartSync.apk**](apk/HeartSync.apk)

### How to Install:
1. Download the `.apk` file above.
2. On your Android device, open the file.
3. If prompted, allow "Install from Unknown Sources" in your settings.
4. Tap **Install** and enjoy!

---

## ✨ Features

✅ **No Login Required** - All data stored locally on device for 100% privacy  
✅ **Premium Emerald UI** - Medical-grade aesthetics with fluid animations  
✅ **Bilingual Support** - English and Nepali language support  
✅ **Minimalist Splash** - Clean, high-end branding with gradient iconography  
✅ **Smart Dashboard** - Real-time heart health status and latest readings  
✅ **Intuitive Entry** - Precision-focused form for systolic/diastolic values  
✅ **Interactive Analytics** - Dynamic line charts with period filtering (Week/Month/Year)  
✅ **Visual Health Indicators** - Color-coded status based on medical standards  

## 🛠️ Architecture

HeartSync follows a modern, decoupled **Provider + Service** architecture:

```
lib/
├── main.dart                 # App entry point & Router
├── providers/
│   └── bp_provider.dart      # Business logic & Reactive State
├── services/
│   └── storage_service.dart  # Persistence layer (Local Storage)
├── screens/
│   ├── splash_screen.dart    # Minimalist Gradient Splash
│   ├── dashboard_screen.dart # High-end Overview & History
│   ├── add_reading_screen.dart # Entry system
│   └── analysis_screen.dart  # Interactive Insights
├── theme/
│   └── app_theme.dart        # Emerald Design System
├── utils/
│   └── localization.dart     # Internationalization
└── widgets/
    └── bp_card.dart          # Reusable analytics cards
```

## 🎨 Design System

### The Emerald Aesthetic
- **Primary Emerald**: `#109B82` (Professional, Trustworthy)
- **Deep Gradient**: `#0B7663` to `#22B89C`
- **Typography**: `Outfit` by Google Fonts (Clean, Modern)
- **Grid System**: 24pt gutter, 32pt corner radius for premium feel.

### Health Status Logic
- **Normal**: Emerald Green (Systolic <120, Diastolic <80)
- **Elevated**: Orange Gold (Systolic 120-139, Diastolic 80-89)
- **High**: Crimson Red (Systolic ≥140, Diastolic ≥90)

## 🏗️ Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Charts**: fl_chart
- **Storage**: SharedPreferences
- **Fonts**: Google Fonts (Outfit)

## 🚀 Running Locally

```bash
# Get dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Run logic
flutter run
```

## 🔒 Privacy

HeartSync is a **local-first** app. We believe your medical data belongs only to you.
- No cloud backups by default.
- No tracking or analytics pixels.
- No account registration required.

## ⚖️ License

Built for health monitoring and educational purposes.
