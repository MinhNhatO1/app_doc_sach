import 'book_model.dart';
import 'user_model.dart';

class Favorite {
  int? id;
  Users? profile;
  List<Book>? books;

  Favorite({this.id, this.profile, required this.books});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    var booksList = json as List<dynamic>;
    List<Book> parsedBooks = booksList.map((item) {
      return Book.fromJson({
        'id': item['id'],
        ...item['attributes'] ?? {},
      });
    }).toList();

    return Favorite(
      id: json['id'],
      profile: Users.fromJson(json['profile']),
      books: parsedBooks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile?.toJson(),
      'books': books?.map((book) => book.toJson()).toList(),
    };
  }
}
