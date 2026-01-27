import 'package:shared_preferences/shared_preferences.dart';
import '../models/bp_record.dart';

class StorageService {
  static const String _key = 'bp_records';

  Future<List<BPRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? recordsJson = prefs.getStringList(_key);
    if (recordsJson == null) return [];
    return recordsJson.map((e) => BPRecord.fromJson(e)).toList();
  }

  Future<void> saveRecord(BPRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recordsJson = prefs.getStringList(_key) ?? [];
    recordsJson.add(record.toJson());
    await prefs.setStringList(_key, recordsJson);
  }

  Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
