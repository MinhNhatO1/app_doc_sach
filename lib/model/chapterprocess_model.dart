import 'chapter_model.dart';

class ChapterProgress {
  int? id;
  Chapter? chapter;
  int pageNumber;
  DateTime lastReadAt;

  ChapterProgress({
    this.id,
    required this.chapter,
    required this.pageNumber,
    required this.lastReadAt,
  });

  factory ChapterProgress.fromJson(Map<String, dynamic> json) {
    return ChapterProgress(
      id: json['id'],
      chapter: json['chapter'] != null && json['chapter']['data'] != null
          ? Chapter.fromJson({'id': json['chapter']['data']['id'],
        ...json['chapter']['data'] ?? {},}) // Lấy phần tử đầu tiên trong mảng chapters.data
          : null,
      pageNumber: json['pageNumber'] ?? 0,
      lastReadAt: DateTime.parse(json['lastReadAt'] ?? '1970-01-01T00:00:00Z'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter': chapter?.toJson(),
      'pageNumber': pageNumber,
      'lastReadAt': lastReadAt.toIso8601String(),
    };
  }
}