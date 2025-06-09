import 'package:cloud_firestore/cloud_firestore.dart';

class MenstruationModel {
  final String? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;

  MenstruationModel({
    this.id,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
  });

  factory MenstruationModel.fromMap(Map<String, dynamic> map, String id) {
    return MenstruationModel(
      id: id,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      cycleLength: map['cycleLength'] ?? 28,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'cycleLength': cycleLength,
    };
  }

  DateTime predictNextPeriod() {
    return DateTime(
      startDate.year,
      startDate.month,
      startDate.day + cycleLength,
    );
  }
}