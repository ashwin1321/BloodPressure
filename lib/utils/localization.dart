class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Blood Pressure',
      'dashboard': 'Dashboard',
      'add_data': 'Add Data',
      'analytics': 'Analytics',
      'systolic': 'Systolic',
      'diastolic': 'Diastolic',
      'save_record': 'Save Record',
      'history': 'History',
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
      'avg_systolic': 'Avg Systolic',
      'avg_diastolic': 'Avg Diastolic',
      'loading': 'Loading...',
      'validation_error': 'Please enter valid values',
      'success_add': 'Record added successfully',
      'mmHg': 'mmHg',
      'today': 'Today',
      'bp_trends': 'BP Trends',
    },
    'ne': {
      'app_title': 'रक्तचाप',
      'dashboard': 'ड्यासबोर्ड',
      'add_data': 'तथ्याङ्क थप्नुहोस्',
      'analytics': 'विश्लेषण',
      'systolic': 'सिस्टोलिक',
      'diastolic': 'डायस्टोलिक',
      'save_record': 'रेकर्ड सुरक्षित गर्नुहोस्',
      'history': 'इतिहास',
      'week': 'हप्ता',
      'month': 'महिना',
      'year': 'वर्ष',
      'avg_systolic': 'औसत सिस्टोलिक',
      'avg_diastolic': 'औसत डायस्टोलिक',
      'loading': 'लोड हुँदैछ...',
      'validation_error': 'कृपया मान्य मानहरू प्रविष्ट गर्नुहोस्',
      'success_add': 'रेकर्ड सफलतापूर्वक थपियो',
      'mmHg': 'mmHg',
      'today': 'आज',
      'bp_trends': 'रक्तचाप प्रवृत्तिहरू',
    },
  };

  static String get(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}
