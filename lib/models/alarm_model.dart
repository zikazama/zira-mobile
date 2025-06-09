class AlarmModel {
  final String? id;
  final String title;
  final String time;
  final List<bool> days; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  final bool isActive;
  final bool isForMe;
  final bool isForPartner;

  AlarmModel({
    this.id,
    required this.title,
    required this.time,
    required this.days,
    required this.isActive,
    required this.isForMe,
    required this.isForPartner,
  });

  factory AlarmModel.fromMap(Map<String, dynamic> map, String id) {
    return AlarmModel(
      id: id,
      title: map['title'] ?? '',
      time: map['time'] ?? '08:00',
      days: List<bool>.from(map['days'] ?? List.filled(7, false)),
      isActive: map['isActive'] ?? false,
      isForMe: map['isForMe'] ?? true,
      isForPartner: map['isForPartner'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time,
      'days': days,
      'isActive': isActive,
      'isForMe': isForMe,
      'isForPartner': isForPartner,
    };
  }

  AlarmModel copyWith({
    String? id,
    String? title,
    String? time,
    List<bool>? days,
    bool? isActive,
    bool? isForMe,
    bool? isForPartner,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      isForMe: isForMe ?? this.isForMe,
      isForPartner: isForPartner ?? this.isForPartner,
    );
  }
}