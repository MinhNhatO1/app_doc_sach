import 'book_model.dart';

class PopularBook {
  int? id;
  Book? book;

  PopularBook({
    this.id,
    this.book,
  });

  factory PopularBook.fromJson(Map<String, dynamic> json) {
    return PopularBook(
      id: json['id'],
      book: json['attributes']['book'] != null ? Book.fromJson({
        'id': json['attributes']['book']['data']['id'],
        ...json['attributes']['book']['data']['attributes'] ?? {},
      }) : null,
    );
  }
}
