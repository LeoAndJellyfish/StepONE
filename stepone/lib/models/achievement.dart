class Achievement {
  final int? id;
  final String title;
  final String description;
  final int categoryId;
  final DateTime achievementDate;
  final String? organization;
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
    required this.achievementDate,
    this.organization,
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
      achievementDate: DateTime.fromMillisecondsSinceEpoch(map['achievement_date']),
      organization: map['organization'],
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
      'achievement_date': achievementDate.millisecondsSinceEpoch,
      'organization': organization,
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
    DateTime? achievementDate,
    String? organization,
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
      achievementDate: achievementDate ?? this.achievementDate,
      organization: organization ?? this.organization,
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
    return 'Achievement(id: $id, title: $title, date: $achievementDate)';
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
