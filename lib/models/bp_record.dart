import 'dart:convert';

class BPRecord {
  final String id;
  final int systolic;
  final int diastolic;
  final DateTime timestamp;

  BPRecord({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BPRecord.fromMap(Map<String, dynamic> map) {
    return BPRecord(
      id: map['id'],
      systolic: map['systolic'],
      // Handle potential string/int mismatch from JSON
      diastolic: map['diastolic'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory BPRecord.fromJson(String source) =>
      BPRecord.fromMap(json.decode(source));
}
