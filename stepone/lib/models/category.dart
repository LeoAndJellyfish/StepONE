class Category {
  final int? id;
  final String name;
  final String code;
  final String description;
  final String color;
  final String icon;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.color = '#6B9FE8',
    this.icon = 'emoji_events',
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      color: map['color'] ?? '#6B9FE8',
      icon: map['icon'] ?? 'emoji_events',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'color': color,
      'icon': icon,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    String? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.code == code;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ code.hashCode;
  }
}
