class Achievement {
  final int? id;
  final String title;
  final String description;
  final int categoryId;
  final String achievementType;
  final DateTime achievementDate;
  final String? awardLevel;
  final String? organization;
  final String? certificateNumber;
  final bool isCollective;
  final bool isLeader;
  final int? participantCount;
  final String? imagePath;
  final String? filePath;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Achievement({
    this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.achievementType,
    required this.achievementDate,
    this.awardLevel,
    this.organization,
    this.certificateNumber,
    this.isCollective = false,
    this.isLeader = false,
    this.participantCount,
    this.imagePath,
    this.filePath,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['category_id']?.toInt() ?? 0,
      achievementType: map['achievement_type'] ?? 'award',
      achievementDate: DateTime.fromMillisecondsSinceEpoch(map['achievement_date']),
      awardLevel: map['award_level'],
      organization: map['organization'],
      certificateNumber: map['certificate_number'],
      isCollective: (map['is_collective'] ?? 0) == 1,
      isLeader: (map['is_leader'] ?? 0) == 1,
      participantCount: map['participant_count']?.toInt(),
      imagePath: map['image_path'],
      filePath: map['file_path'],
      remarks: map['remarks'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'achievement_type': achievementType,
      'achievement_date': achievementDate.millisecondsSinceEpoch,
      'award_level': awardLevel,
      'organization': organization,
      'certificate_number': certificateNumber,
      'is_collective': isCollective ? 1 : 0,
      'is_leader': isLeader ? 1 : 0,
      'participant_count': participantCount,
      'image_path': imagePath,
      'file_path': filePath,
      'remarks': remarks,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Achievement copyWith({
    int? id,
    String? title,
    String? description,
    int? categoryId,
    String? achievementType,
    DateTime? achievementDate,
    String? awardLevel,
    String? organization,
    String? certificateNumber,
    bool? isCollective,
    bool? isLeader,
    int? participantCount,
    String? imagePath,
    String? filePath,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      achievementType: achievementType ?? this.achievementType,
      achievementDate: achievementDate ?? this.achievementDate,
      awardLevel: awardLevel ?? this.awardLevel,
      organization: organization ?? this.organization,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      isCollective: isCollective ?? this.isCollective,
      isLeader: isLeader ?? this.isLeader,
      participantCount: participantCount ?? this.participantCount,
      imagePath: imagePath ?? this.imagePath,
      filePath: filePath ?? this.filePath,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, type: $achievementType, date: $achievementDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.achievementDate == achievementDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        categoryId.hashCode ^
        achievementDate.hashCode;
  }
}
