import 'package:app_doc_sach/model/book_model.dart';
import 'package:app_doc_sach/model/user_model.dart';

class Comment {
  final int id;
  final String text; // Nội dung bình luận
  final Users? profile; // Người dùng
  final Book? book; // Cuốn sách
  final DateTime dateComment; // Ngày bình luận

  Comment({
    required this.id,
    required this.text,
    required this.profile,
    required this.book,
    required this.dateComment,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['attributes']['text'] ?? '',
      profile: json['attributes']['profile'] != null && json['attributes']['profile']['data'] != null
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
      dateComment: DateTime.parse(json['attributes']['dateComment'] ?? DateTime.now().toIso8601String()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'profile': profile!.toJson(),
      'book': book!.toJson(),
      'dateComment': dateComment.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Comment{id: $id, text: $text, profile: ${profile?.fullName}, book: ${book?.title}, dateComment: $dateComment}';
  }

}