class FileAttachment {
  final int? id;
  final int achievementId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String? mimeType;
  final DateTime uploadedAt;

  const FileAttachment({
    this.id,
    required this.achievementId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    this.mimeType,
    required this.uploadedAt,
  });

  factory FileAttachment.fromMap(Map<String, dynamic> map) {
    return FileAttachment(
      id: map['id']?.toInt(),
      achievementId: map['achievement_id']?.toInt() ?? 0,
      fileName: map['file_name'] ?? '',
      filePath: map['file_path'] ?? '',
      fileType: map['file_type'] ?? '',
      fileSize: map['file_size']?.toInt() ?? 0,
      mimeType: map['mime_type'],
      uploadedAt: DateTime.fromMillisecondsSinceEpoch(map['uploaded_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'achievement_id': achievementId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'mime_type': mimeType,
      'uploaded_at': uploadedAt.millisecondsSinceEpoch,
    };
  }

  FileAttachment copyWith({
    int? id,
    int? achievementId,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    String? mimeType,
    DateTime? uploadedAt,
  }) {
    return FileAttachment(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  String toString() {
    return 'FileAttachment(id: $id, fileName: $fileName, type: $fileType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileAttachment &&
        other.id == id &&
        other.fileName == fileName &&
        other.filePath == filePath;
  }

  @override
  int get hashCode {
    return id.hashCode ^ fileName.hashCode ^ filePath.hashCode;
  }
}
