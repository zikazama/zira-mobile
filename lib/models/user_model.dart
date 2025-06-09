import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? partnerId;
  final String? partnerEmail;
  final DateTime? relationshipDate;
  final String? fcmToken;
  final List<String>? backgroundImages;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.partnerId,
    this.partnerEmail,
    this.relationshipDate,
    this.fcmToken,
    this.backgroundImages,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'],
      partnerId: map['partnerId'],
      partnerEmail: map['partnerEmail'],
      relationshipDate:
          map['relationshipDate'] != null
              ? (map['relationshipDate'] as Timestamp).toDate()
              : null,
      fcmToken: map['fcmToken'],
      backgroundImages:
          map['backgroundImages'] != null
              ? List<String>.from(map['backgroundImages'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'partnerId': partnerId,
      'partnerEmail': partnerEmail,
      'relationshipDate': relationshipDate,
      'fcmToken': fcmToken,
      'backgroundImages': backgroundImages,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? partnerId,
    String? partnerEmail,
    DateTime? relationshipDate,
    String? fcmToken,
    List<String>? backgroundImages,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      partnerId: partnerId ?? this.partnerId,
      partnerEmail: partnerEmail ?? this.partnerEmail,
      relationshipDate: relationshipDate ?? this.relationshipDate,
      fcmToken: fcmToken ?? this.fcmToken,
      backgroundImages: backgroundImages ?? this.backgroundImages,
    );
  }
}
