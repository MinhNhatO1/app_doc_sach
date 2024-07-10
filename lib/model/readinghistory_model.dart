import 'package:app_doc_sach/model/chapter_model.dart';
import 'package:app_doc_sach/model/user_model.dart';
import 'package:app_doc_sach/model/book_model.dart';

import 'chapterprocess_model.dart'; // Import your Book model here

class ReadingHistory {
  int? id;
  Users? user;
  Book? book;
  List<ChapterProgress> chapterProgress;
  DateTime lastReadAt;

  ReadingHistory({
    this.id,
    required this.user,
    required this.book,
    required this.chapterProgress,
    required this.lastReadAt,
  });

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    List<ChapterProgress> progress = [];
    if (json['attributes']['chapter_processes'] != null &&
        json['attributes']['chapter_processes']['data'] != null) {
      progress = List<ChapterProgress>.from(json['attributes']['chapter_processes']['data']
          .map((item) {
        // Ensure 'id' is parsed as an integer
        int id = int.tryParse(item['id'].toString()) ?? 0;

        return ChapterProgress.fromJson({
          'id': id,
          ...item['attributes'] ?? {},
        });
      })
          .toList());
    }

    return ReadingHistory(
      id: json['id'],
      user: json['attributes']['profile'] != null && json['attributes']['profile']['data'] != null
          ? Users.fromJson({
        'id': json['attributes']['profile']['data']['id'],
        ...json['attributes']['profile']['data']['attributes'] ?? {},
      })
          : null,
      book: json['attributes']['book'] != null && json['attributes']['book']['data'] != null
          ? Book.fromJson({
        'id': json['attributes']['book']['data']['id'],
        ...json['attributes']['book']['data']['attributes'] ?? {},
      })
          : null,
      chapterProgress: progress,
      lastReadAt: DateTime.parse(json['attributes']['lastReadAt'] ?? '1970-01-01T00:00:00Z'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'book': book?.toJson(),
      'chapterProgress': chapterProgress.map((e) => e.toJson()).toList(),
      'lastReadAt': lastReadAt.toIso8601String(),
    };
  }
}
