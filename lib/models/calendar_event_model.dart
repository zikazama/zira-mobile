import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEventModel {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String creatorId;
  final String? imageUrl;

  CalendarEventModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.creatorId,
    this.imageUrl,
  });

  factory CalendarEventModel.fromMap(Map<String, dynamic> map, String id) {
    return CalendarEventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      creatorId: map['creatorId'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'creatorId': creatorId,
      'imageUrl': imageUrl,
    };
  }
}