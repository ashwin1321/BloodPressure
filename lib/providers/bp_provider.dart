import 'package:flutter/material.dart';
import '../models/bp_record.dart';
import '../services/storage_service.dart';

class BPProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<BPRecord> _records = [];
  bool _isLoading = false;
  String _languageCode = 'en';

  List<BPRecord> get records => _records;
  bool get isLoading => _isLoading;
  String get languageCode => _languageCode;

  BPProvider() {
    loadRecords();
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    _records = await _storageService.getRecords();
    _records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(int systolic, int diastolic) async {
    final record = BPRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      systolic: systolic,
      diastolic: diastolic,
      timestamp: DateTime.now(),
    );

    await _storageService.saveRecord(record);
    await loadRecords();
  }

  void toggleLanguage() {
    _languageCode = _languageCode == 'en' ? 'ne' : 'en';
    notifyListeners();
  }

  List<BPRecord> getRecordsForPeriod(String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(Duration(days: 30));
        break;
      case 'year':
        startDate = now.subtract(Duration(days: 365));
        break;
      default:
        return _records;
    }

    return _records
        .where((record) => record.timestamp.isAfter(startDate))
        .toList();
  }

  Map<String, double> getAverages(List<BPRecord> records) {
    if (records.isEmpty) {
      return {'systolic': 0, 'diastolic': 0};
    }

    final avgSystolic =
        records.map((r) => r.systolic).reduce((a, b) => a + b) / records.length;
    final avgDiastolic =
        records.map((r) => r.diastolic).reduce((a, b) => a + b) /
        records.length;

    return {'systolic': avgSystolic, 'diastolic': avgDiastolic};
  }
}
